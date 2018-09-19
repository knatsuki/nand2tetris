require_relative '../parser'

describe Parser do
  let(:file_initial) { instance_double("IO") }
  let(:instance) { described_class.new(file_initial) }
  let(:s) { 'sfdsafsj' }

  before do
    allow(file_initial).to receive(:gets).and_return(s)
  end

  describe '#initializer' do
    before do
      instance
    end

    it 'initializes correctly' do
      expect(instance.instance_variable_get(:@file)).to eq(file_initial)
      expect(instance.instance_variable_get(:@current_line)).to eq(s)
      expect(instance.instance_variable_get(:@line_number)).to eq(0)
    end
  end

  describe '#has_more_commands' do
    context '@current_line is string' do
      before do
        instance.instance_variable_set(:@current_line, '')
      end

      it 'returns true' do
        expect(instance.has_more_commands).to be true
      end
    end

    context '@current_line is nil' do
      before do
        instance.instance_variable_set(:@current_line, nil)
      end

      it 'returns false' do
        expect(instance.has_more_commands).to be false
      end
    end
  end

  describe '#rewind' do
    before do
      allow(file_initial).to receive(:rewind)
      instance.instance_variable_set(:@line_number, 2)

      instance.rewind
    end

    it 'calls @file.rewind' do
      expect(file_initial).to have_received(:rewind).once
    end

    it 'sets @line_number back to zero' do
      expect(instance.instance_variable_get(:@line_number)).to eq(0)
    end
  end

  describe '#current_line' do
    let(:input) {}
    let(:output) {}

    before do
      instance.instance_variable_set(:@current_line, input)
    end

    context 'in-line comment' do
      let(:input) { 'fsdfsdfa // sfsfdsfsdfsd' }
      let(:output) { 'fsdfsdfa' }

      it 'parses as expected' do
        expect(instance.current_line).to eq(output)
      end
    end

    context 'line comment' do
      let(:input) { '// sfsfdsfsdfsd' }
      let(:output) { '' }

      it 'parses as expected' do
        expect(instance.current_line).to eq(output)
      end
    end

    context 'general commands' do
      let(:input) { 'sfsfdsfsdfsd' }
      let(:output) { 'sfsfdsfsdfsd' }

      it 'parses as expected' do
        expect(instance.current_line).to eq(output)
      end
    end

    context 'no line' do
      let(:input) { nil }
      let(:output) { nil }

      it 'parses as expected' do
        expect(instance.current_line).to eq(output)
      end
    end
  end

  describe '#command_type' do
    let(:current_line) {}

    before do 
      allow(instance).to receive(:current_line).and_return(current_line)
    end

    context 'comment line' do
      let(:current_line) { '' }

      it 'returns corrent command type' do
        expect(instance.command_type).to eq('COMMENT')
      end
    end 

    context 'label line' do
      let(:current_line) { '(xxx)' }

      it 'returns corrent command type' do
        expect(instance.command_type).to eq('L_COMMAND')
      end
    end 

    context 'variable line' do
      let(:current_line) { '@sadfsdf' }

      it 'returns corrent command type' do
        expect(instance.command_type).to eq('A_COMMAND')
      end
    end 

    context 'command line' do
      let(:current_line) { 'sadfsdf' }

      it 'returns corrent command type' do
        expect(instance.command_type).to eq('C_COMMAND')
      end
    end 
  end

  describe '#symbol' do
    let(:current_line) {}

    before do 
      allow(instance).to receive(:current_line).and_return(current_line)
    end

    context 'label line' do
      let(:current_line) { '(xxx)' }
      let(:output) { 'xxx' }

      it 'returns correct value' do
        expect(instance.symbol).to eq(output)
      end
    end

    context 'symbol line' do
      let(:current_line) { '@xxx' }
      let(:output) { 'xxx' }

      it 'returns correct value' do
        expect(instance.symbol).to eq(output)
      end
    end
  end

  describe '#dest' do
    let(:current_line) { 'dest=comp;jump' }
    let(:output) { 'dest' }

    before do 
      allow(instance).to receive(:current_line).and_return(current_line)
    end

    it 'parses correct value' do
      expect(instance.dest).to eq(output)
    end
  end

  describe '#comp' do
    let(:current_line) { 'dest=comp;jump' }
    let(:output) { 'comp' }

    before do 
      allow(instance).to receive(:current_line).and_return(current_line)
    end

    it 'returns correct value' do
      expect(instance.comp).to eq(output)
    end
  end

  describe '#jump' do
    let(:current_line) { 'dest=comp;jump' }
    let(:output) { 'jump' }

    before do 
      allow(instance).to receive(:current_line).and_return(current_line)
    end

    it 'returns correct value' do
      expect(instance.jump).to eq(output)
    end
  end

  describe '#advance' do
    let(:file) { instance_double("IO") }
    let(:str) { 'dsfsadfs' }
    let(:command_type) {}
    let(:line_number) { 3 }

    before do
      allow(file).to receive(:gets).and_return(str)
      instance.instance_variable_set(:@file, file)

      instance.instance_variable_set(:@line_number, line_number)
      allow(instance).to receive(:command_type).and_return(command_type)

      instance.advance
    end

    it 'sets @current_line to streamed line' do
      expect(instance.instance_variable_get(:@current_line)).to eq(str)
    end

    context 'comment line' do
      let(:command_type) { 'COMMENT' }

      it 'does not iterate @line_number' do
        expect(instance.instance_variable_get(:@line_number)).to eq(line_number)
      end
    end

    context 'label line' do
      let(:command_type) { 'L_COMMAND' }

      it 'does not iterate @line_number' do
        expect(instance.instance_variable_get(:@line_number)).to eq(line_number)
      end
    end

    context 'variable line' do
      let(:command_type) { 'A_COMMAND' }

      it 'iterates @line_number' do
        expect(instance.instance_variable_get(:@line_number)).to eq(line_number + 1)
      end
    end

    context 'variable line' do
      let(:command_type) { 'C_COMMAND' }

      it 'iterates @line_number' do
        expect(instance.instance_variable_get(:@line_number)).to eq(line_number + 1)
      end
    end
  end
end
