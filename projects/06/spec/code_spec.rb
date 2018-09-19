require_relative '../code'

describe Code do
  let(:subject) { Code }
  describe '::DEST' do
    let(:expected_hash) do
      {
        nil => '000',
        'M' => '001',
        'D' => '010',
        'MD' => '011',
        'A' => '100',
        'AM' => '101',
        'AD' => '110',
        'AMD' => '111',
      }
    end

    it 'returns correct hash' do
      expect(subject::DEST).to eq(expected_hash)
    end
  end
  describe '::JUMP' do
    let(:expected_hash) do
      {
        nil => '000',
        'JGT' => '001',
        'JEQ' => '010',
        'JGE' => '011',
        'JLT' => '100',
        'JNE' => '101',
        'JLE' => '110',
        'JMP' => '111',
      }
    end

    it 'returns correct hash' do
      expect(subject::JUMP).to eq(expected_hash)
    end
  end

  describe '::COMP' do
    let(:expected_hash) do
      {
        '0' => '0101010',
        '1' => '0111111',
        '-1' => '0111010',
        'D' => '0001100',
        'A' => '0110000',
        'M' => '1110000',
        '!D' => '0001101',
        '!A' => '0110001',
        '!M' => '1110001',
        '-D' => '0001111',
        '-A' => '0110011',
        '-M' => '1110011',
        'D+1' => '0011111',
        'A+1' => '0110111',
        'M+1' => '1110111',
        'D-1' => '0001110',
        'A-1' => '0110010',
        'M-1' => '1110010',
        'D+A' => '0000010',
        'D+M' => '1000010',
        'D-A' => '0010011',
        'D-M' => '1010011',
        'A-D' => '0000111',
        'M-D' => '1000111',
        'D&A' => '0000000',
        'D&M' => '1000000',
        'D|A' => '0010101',
        'D|M' => '1010101',      
      }
    end

    it 'returns correct hash' do
      expect(subject::COMP).to eq(expected_hash)
    end
  end

  describe 'self.dest' do
    let(:arg) { 'string_argument' }
    let(:val) { 'expected_value' }
    let(:constant_stub) do
      { arg => val }
    end

    before do
      stub_const('Code::DEST', constant_stub)
    end

    it 'returns value corresponding to DEST[key]' do
      expect(subject.dest(arg)).to eq(val)
    end   
  end

  describe 'self.jump' do
    let(:arg) { 'string_argument' }
    let(:val) { 'expected_value' }
    let(:constant_stub) do
      { arg => val }
    end

    before do
      stub_const('Code::JUMP', constant_stub)
    end

    it 'returns value corresponding to JUMP[key]' do
      expect(subject.jump(arg)).to eq(val)
    end   
  end

  describe 'self.comp' do
    let(:arg) { 'string_argument' }
    let(:val) { 'expected_value' }
    let(:constant_stub) do
      { arg => val }
    end

    before do
      stub_const('Code::COMP', constant_stub)
    end

    it 'returns value corresponding to COMP[key]' do
      expect(subject.comp(arg)).to eq(val)
    end   
  end
end
