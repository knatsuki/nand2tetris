class CodeWriter
  def initialize(file)
    @file = file
    @counts = {
      :eq => 0,
      :gt => 0,
      :lt => 0,
    }
    @file_name = nil
  end

  def close
    # closes the file
    @file.close
  end

  def set_file_name(file_name)
    @file_name = file_name
  end

  def file_name
    raise '@file_name must first best set' if @file_name.nil?
    @file_name
  end

  def write_arithmetic(command)
    # writes the asm code for the given arithmentic command
    case command
    when 'add'
      write_add
    when 'sub'
      write_sub
    when 'neg'
      write_neg
    when 'eq'
      write_eq
    when 'gt'
      write_gt
    when 'lt'
      write_lt
    when 'and'
      write_and
    when 'or'
      write_or
    when 'not'
      write_not
    end
  end


  def write_pop(segment, idx)
    if segment == 'constant'
      @file.puts(
        '// Pop Constant',
        '@SP',
        'M=M-1',
        'A=M',
        'D=M',
        "@#{idx}",
        'M=D',
      )      
    elsif segment == 'static'
      @file.puts(
        '// Pop Static',
        '@SP',
        'M=M-1',
        'A=M',
        'D=M',
        "@#{file_name}.#{idx}",
        'M=D',
      )      
    elsif segment == 'local'
      @file.puts('// Pop Local', pop_template_1('LCL', idx))
    elsif segment == 'argument'
      @file.puts('// Pop Argument', pop_template_1('ARG', idx))
    elsif segment == 'this'
      @file.puts('// Pop This', pop_template_1('THIS', idx))
    elsif segment == 'that'
      @file.puts('// Pop That', pop_template_1('THAT', idx))      
    elsif segment == 'pointer'
      @file.puts('// Pop Pointer', pop_template_2('R3', idx))      
    elsif segment == 'temp'
      @file.puts('// Pop Temp', pop_template_2('R5', idx))      
    end
  end

  def push_template_1(symbol, idx)
    [
      "@#{symbol}",
      'D=M',
      "@#{idx}",
      'A=A+D',
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1',      
    ]
  end

  def push_template_2(symbol, idx)
    [
      "@#{symbol}",
      'D=A',
      "@#{idx}",
      'A=A+D',
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1',      
    ]
  end

  def write_push(segment, idx)
    if segment == 'constant'
      @file.puts(
        '// Push Constant',
        "@#{idx}",
        'D=A',
        '@SP',
        'A=M',
        'M=D',
        '@SP',
        'M=M+1',      
      )      
    elsif segment == 'static'
      @file.puts(
        '// Push Static',
        "@#{file_name}.#{idx}",
        'D=M',
        '@SP',
        'A=M',
        'M=D',
        '@SP',
        'M=M+1',      
      )      
    elsif segment == 'local'
      @file.puts('// Push Local', push_template_1('LCL', idx))
    elsif segment == 'argument'
      @file.puts('// Push Argument', push_template_1('ARG', idx))
    elsif segment == 'this'
      @file.puts('// Push This', push_template_1('THIS', idx))
    elsif segment == 'that'
      @file.puts('// Push That', push_template_1('THAT', idx))      
    elsif segment == 'pointer'
      @file.puts('// Push Pointer', push_template_2('R3', idx))      
    elsif segment == 'temp'
      @file.puts('// Push Temp', push_template_2('R5', idx))      
    end
  end

  private
  
  def write_add
    @file.puts(
      '// Add',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'M=M+D',
    )
  end

  def write_sub
    @file.puts(
      '// Subtract',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'M=M-D',
    )
  end

  def write_and
    @file.puts(
      '// And',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'M=D&M',
    )
  end

  def write_or
    @file.puts(
      '// Or',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'M=D|M',
    )
  end

  def write_eq
    @file.puts(
      '// Eq',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'D=M-D',
      "@EQ_TRUE_#{@counts[:eq]}",
      'D;JEQ',
      '@SP',
      'A=M-1',
      'M=0',
      "@EQ_END_#{@counts[:eq]}",
      '0;JMP',
      "(EQ_TRUE_#{@counts[:eq]})",
      '@SP',
      'A=M-1',
      'M=-1',
      "(EQ_END_#{@counts[:eq]})",
    )

    @counts[:eq] = @counts[:eq] + 1
  end

  def write_gt
    @file.puts(
      '// Gt',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'D=M-D',
      "@GT_TRUE_#{@counts[:gt]}",
      'D;JGT',
      '@SP',
      'A=M-1',
      'M=0',
      "@GT_END_#{@counts[:gt]}",
      '0;JMP',
      "(GT_TRUE_#{@counts[:gt]})",
      '@SP',
      'A=M-1',
      'M=-1',
      "(GT_END_#{@counts[:gt]})",
    )

    @counts[:gt] = @counts[:gt] + 1
  end

  def write_lt
    @file.puts(
      '// Lt',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      'A=A-1',
      'D=M-D',
      "@LT_TRUE_#{@counts[:lt]}",
      'D;JLT',
      '@SP',
      'A=M-1',
      'M=0',
      "@LT_END_#{@counts[:lt]}",
      '0;JMP',
      "(LT_TRUE_#{@counts[:lt]})",
      '@SP',
      'A=M-1',
      'M=-1',
      "(LT_END_#{@counts[:lt]})",
    )

    @counts[:lt] = @counts[:lt] + 1
  end

  def write_neg
    @file.puts(
      '// Neg',
      '@SP',
      'A=M-1',
      'M=-M',
    )
  end

  def write_not
    @file.puts(
      '// Not',
      '@SP',
      'A=M-1',
      'M=!M',
    )
  end

  def pop_template_1(symbol, idx)
    [
      "@#{symbol}",
      'D=M',
      "@#{idx}",
      'D=A+D',
      '@R13',
      'M=D',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      '@R13',
      'A=M',
      'M=D',
    ]
  end

  def pop_template_2(symbol, idx)
    [
      "@#{symbol}",
      'D=A',
      "@#{idx}",
      'D=A+D',
      '@R13',
      'M=D',
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      '@R13',
      'A=M',
      'M=D',
    ]
  end
end
