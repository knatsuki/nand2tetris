class CodeWriter
  def initialize(file)
    @file = file
    @counts = {
      :eq => 0,
      :gt => 0,
      :lt => 0,
      :call => 0,
    }
    @file_name = nil
    @function_name = nil
  end

  def close
    # closes the file
    @file.close
  end

  def set_file_name(file_name)
    @file_name = file_name
  end

  def write_init
    @file.puts(set_symbol_template_1('SP',256))
    write_call('Sys.init', 0)
  end

  def write_label(label_name)
    @file.puts(
      label_template(function_label(label_name)),
    )          
  end

  def write_goto(label_name)
    @file.puts(goto_template(function_label(label_name)))          
  end


  def write_if_goto(label_name)
    @file.puts(
      '@SP',
      'M=M-1',
      'A=M',
      'D=M',
      "@#{function_label(label_name)}",
      'D;JNE',
    )          
  end

  def write_function(fn_name, num_locals)
    @file.puts(
      '// FUNCTION',
      label_template(fn_name),
    )
    num_locals.times { write_push('constant', 0) }

    set_function_name(fn_name) # set function name for labels
  end

  def write_call(fn_name, num_args)

    @file.puts(
      '// CALL',
      push_symbol_address_template(return_address_label_name),
      push_symbol_value_template('LCL'),
      push_symbol_value_template('ARG'),
      push_symbol_value_template('THIS'),
      push_symbol_value_template('THAT'),
      set_symbol_template_3('ARG', 'SP', 5+num_args, false),
      set_symbol_template_1('LCL','SP'), 
      goto_template(fn_name),
      label_template(return_address_label_name),
    )

    @counts[:call] = @counts[:call] + 1
  end

  def write_return
    @file.puts(
      '// Return',
      set_symbol_template_1('R14','LCL'), # LCL temp 
      set_symbol_template_2('R15','R14', 5, false), # return address temp 
      pop_template_1('ARG', 0), # *(ARG) = pop()
      set_symbol_template_3('SP', 'ARG', 1, true),
      set_symbol_template_2('THAT','R14', 1, false),
      set_symbol_template_2('THIS','R14', 2, false),
      set_symbol_template_2('ARG','R14', 3, false),
      set_symbol_template_2('LCL','R14', 4, false),
      [
        '@R15',
        'A=M',
        '0;JMP',      
      ]
    )
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


  def write_push(segment, idx)
    if segment == 'constant'
      @file.puts('// Push Constant', push_constant_template(idx))      
    elsif segment == 'static'
      @file.puts('// Push Static', push_static_template(idx))      
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

  def set_function_name(function_name)
    @function_name = function_name
  end

  def file_name
    raise '@file_name must first best set' if @file_name.nil?
    @file_name
  end

  def function_name
    '' if @function_name.nil?
    @function_name
  end

  def function_label(label_name)
    "#{function_name}$#{label_name}"
  end

  def return_address_label_name
    "#{function_name}$RETURN_ADDRESS_#{@counts[:call]}"
  end
  
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

  def label_template(label)
    [
      "(#{label})",
    ]
  end

  def goto_template(label)
    [
      "@#{label}",
      "0;JMP",      
    ]
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

  def push_constant_template(idx)
    [
      "@#{idx}",
      'D=A',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1',      
    ]
  end

  def push_static_template(idx)
    [
      "@#{file_name}.#{idx}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1',      
    ]
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

  def push_symbol_address_template(symbol_name) 
    [
      "@#{symbol_name}",
      'D=A',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1',
    ]
  end

  def push_symbol_value_template(symbol_name) 
    [
      "@#{symbol_name}",
      'D=M',
      '@SP',
      'A=M',
      'M=D',
      '@SP',
      'M=M+1',
    ]
  end

  def set_symbol_template_1(symbol, arg)
    # set value of @symbol to @arg's value
    # *symbol = *arg
    [
      "@#{arg}",
      "D=#{arg.is_a?(Integer) ? 'A' : 'M'}",
      "@#{symbol}", 
      'M=D',
    ]
  end

  def set_symbol_template_2(symbol, arg, offset, is_add = true)
    # symbol = *(arg + offset)
    [
      "@#{offset}",
      'D=A',
      "@#{arg}",
      "D=M#{is_add ? '+' : '-'}D",
      'A=D', 
      'D=M',
      "@#{symbol}", 
      'M=D',
    ]
  end

  def set_symbol_template_3(symbol, arg, offset, is_add = true)
    # symbol = arg + offset

    [
      "@#{offset}",
      'D=A',
      "@#{arg}",
      "D=M#{is_add ? '+' : '-'}D",
      "@#{symbol}", 
      'M=D',
    ]
  end

  # def symbol_operation_template(expr)
  #   subject =  expr[/(.+)=(.+)/, 1]
  #   body = expr[/(.+)=(.+)/, 2]
  #   set_to_address_value = !!body[/\*\((.+)\)/] #ex. *(SP - 5) -> true; SP - 5 -> false

  #   body = body[/\*\((.+)\)/, 1] if set_to_address_value

  #   # parse body
  #   # ex. SP - 5 
  #   # => 
  #   # body_arg_1 = 'SP'
  #   # body_has_arithmetic = true
  #   # is_add = false
  #   # body_arg_2 = '5'

  #   body_arg_1 = body[/([^+-]+)(([+-])(.+))?/, 1]
  #   body_arg_1_is_int = body_arg_1.to_i.to_s == body_arg_1
  #   body_has_arithmetic = !!body[/([^+-]+)(([+-])(.+))?/, 2]
  #   is_add = body[/([^+-]+)(([+-])(.+))?/, 3] == '+'
  #   body_arg_2 = body[/([^+-]+)(([+-])(.+))?/, 4]

  #   template = []

  #   if body_has_arithmetic
  #     template += [
  #       "@#{body_arg_2}",
  #       'D=A',
  #       "@#{body_arg_1}",
  #       "D=#{body_arg_1_is_int ? 'A' : 'M'}#{is_add ? '+' : '-'}D",
  #     ]      
  #   else
  #     template += [
  #       "@#{body_arg_1}",
  #       "D=#{body_arg_1_is_int ? 'A' : 'M'}",
  #     ]
  #   end

  #   if set_to_address_value
  #     template = template + ['A=D', 'D=M']
  #   end

  #   template + ["@#{subject}", 'M=D']
  # end
end
