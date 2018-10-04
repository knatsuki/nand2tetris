class ASMSymbolTable
  DEFAULT_TABLE = {
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

  def initialize
    @table = DEFAULT_TABLE.clone
    @next_address_num = 16
  end

  def add_entry(sym, address)
    @table[sym] = address
  end

  def contains(sym)
    @table.key?(sym) || sym_is_num?(sym)
  end

  def get_address(sym)
    if @table.key?(sym)
      @table[sym]
    elsif sym_is_num?(sym)
      generate_address_from_num(sym.to_i)
    end
  end

  def sym_is_num?(sym)
    sym.to_i.to_s == sym
  end

  def add_address(sym)
    add_entry(sym, generate_address_from_num(@next_address_num))
    @next_address_num =  @next_address_num + 1
  end

  def add_label(sym, line_number)
    add_entry(sym, generate_address_from_num(line_number))
  end

  def generate_address_from_num(num)
    num_base_2 = num.to_s(2)
    num_0_prepend = 15 - num_base_2.length

    '0' * num_0_prepend + num_base_2
  end
end
