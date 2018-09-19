require_relative '../symbol_table';

describe SymbolTable do
  let(:instance) { described_class.new }

  describe 'SymbolTable::DEFAULT_TABLE' do
    let(:expected_table) do
      {
        'SP'=> '000000000000000',
        'LCL'=> '000000000000001',
        'ARG'=> '000000000000010',
        'THIS'=> '000000000000011',
        'THAT'=> '000000000000100',
        'R0'=> '000000000000000',
        'R1'=> '000000000000001',
        'R2'=> '000000000000010',
        'R3'=> '000000000000011',
        'R4'=> '000000000000100',
        'R5'=> '000000000000101',
        'R6'=> '000000000000110',
        'R7'=> '000000000000111',
        'R8'=> '000000000001000',
        'R9'=> '000000000001001',
        'R10'=> '00000000001010',
        'R11'=> '000000000001011',
        'R12'=> '000000000001100',
        'R13'=> '000000000001101',
        'R14'=> '000000000001110',
        'R15'=> '000000000001111',
        'SCREEN'=> '100000000000000',
        'KBD'=> '110000000000000',
      }
    end

    it 'is expected' do
      expect(described_class::DEFAULT_TABLE).to eq(expected_table)
    end
  end

  describe '@table' do
    it 'is equal to ::DEFAULT_TABLE on initialization' do
      expect(instance.instance_variable_get(:@table)).to eq(described_class::DEFAULT_TABLE)
    end
  end

  describe '#add_entry' do
    let(:sym) { 'LOOP' }
    let(:address) { '000000000001231' }

    before { instance.add_entry(sym, address) }

    it 'adds entry to @table' do
      expect(instance.instance_variable_get(:@table)[sym]).to eq(address)
    end
  end

  describe '#contains' do
    context 'sym exists' do
      let(:sym) { 'SCREEN' }

      it 'returns true' do expect(instance.contains(sym)).to eq(true) end
    end

    context 'sym does not exist' do
      let(:sym) { 'LOOPAAA' }

      it 'returns false' do expect(instance.contains(sym)).to eq(false) end
    end
  end

  describe '#get_address' do
    let(:sym) { 'SCREEN' }    
    let(:expected_address) { '100000000000000' }

    it 'returns address corresponding to symbol' do
      expect(instance.get_address(sym)).to eq(expected_address)
    end
  end
end