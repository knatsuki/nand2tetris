class JackVMWriter
  def initialize(vm_file)
    @vm_file = vm_file
  end

  def write_push(segment, index)
    # PUSH *(segment + index) to stack
    raise_invalid_segment unless valid_segment?(segment)

    @vm_file.puts("push #{segment} #{index}")
  end

  def write_pop(segment, index)
    # POP stack and write to *(segment + index)
    raise_invalid_segment unless valid_segment?(segment)

    @vm_file.puts("pop #{segment} #{index}")
  end

  def write_arithmetic(operator, is_unary = false)
    command = ''
    if is_unary
      command = unary_op_map(operator)
    else
      command = op_map(operator)
    end

    @vm_file.puts(command)
  end

  def write_label(lbl)
    # write VM label command
    @vm_file.puts("label #{lbl}")

  end

  def write_go_to(lbl)
    # write VM goTo command
    @vm_file.puts("goto #{lbl}")
  end

  def write_if(lbl)
    # write VM goTo command
    @vm_file.puts("if-goto #{lbl}")
  end

  def write_call(name, num_args)
    # write VM call command
    @vm_file.puts("call #{name} #{num_args}")
  end

  def write_function(name, num_locals)
    # write VM fuction command
    @vm_file.puts("function #{name} #{num_locals}")
  end

  def write_return
    # write VM return command
    @vm_file.puts('return')
  end

  private
  def valid_segment?(segment)
    [
      'constant',
      'argument',
      'local',
      'static',
      'this',
      'that',
      'pointer',
      'temp',
    ].include?(segment)
  end

  def raise_invalid_segment
    raise 'Invalid segment'
  end

  def valid_arithmetic?(command)
    [
      'add',
      'sub',
      'neg',
      'eq',
      'gt',
      'lt',
      'and',
      'or',
      'not',
    ].include?(command)
  end

  def op_map(op)
    {
      '+' => 'add',
      '-' => 'sub',
      '&' => 'and',
      '|' => 'or',
      '<' => 'lt',
      '>' => 'gt',
      '=' => 'eq',
    }[op]
  end

  def unary_op_map(op)
    {
      '-' => 'neg',
      '~' => 'not',
    }[op]
  end
end