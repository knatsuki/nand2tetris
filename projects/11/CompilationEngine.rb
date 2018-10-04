require_relative './JackTokenizer'
require_relative './VMWriter'
require_relative './SymbolTable'

class CompilationEngine
  def initialize(file_texts:, xml_file:, vm_file:)
    @tokenizer = JackTokenizer.new(file_texts)
    @xml_file = xml_file
    @vm_writer = VMWriter.new(vm_file)
    # SymbolTable-related fields
    @symbol_table = SymbolTable.new
    @current_class_name = ''
    @current_subroutine = { name: '', type: '' }
    @while_loop_count = 0
    @if_loop_count = 0

    tokenizer.advance

    compile_class
  end

  def tokenizer
    @tokenizer
  end

  def xml_file
    @xml_file
  end

  def compile_class
    begin_terminal('class')
    compile_first_token_for('class')

    set_current_class_name

    compile_class_name
    compile_token('{')
    compile_class_var_dec('*')
    compile_subroutine_dec('*')
    compile_token('}')

    end_terminal('class')
  end

  def compile_class_var_dec(opt = nil)
    return if (optional?(opt) && !starting_token_for?('class_var_dec'))

    begin_terminal('classVarDec')

    kind = declarator_to_kind_map(@tokenizer.token)

    compile_first_token_for('class_var_dec')

    type = compile_type

    compile_var_name('+', { kind: kind, type: type })
    compile_token(';')

    end_terminal('classVarDec')

    if (repeat?(opt) && starting_token_for?('class_var_dec'))
        compile_class_var_dec(opt)
    end
  end

  def compile_type
    type = @tokenizer.token

    compile_first_token_for('type')

    return type
  end

  def compile_class_name(opt = nil)
    return if (optional?(opt) && !starting_token_for?('class_name'))

    compile_first_token_for('class_name')
  end

  def compile_var_name(opt = nil, type: nil, kind: nil)
    return if (optional?(opt) && !starting_token_for?('var_name'))

    if (kind && type)
      define_in_symbol_table({
        name: @tokenizer.token,
        type: type,
        kind: kind,
      })
    end

    compile_first_token_for('var_name')

    repeat_with_comma?(opt) { compile_var_name('+', { type: type, kind: kind }) }
  end

  def compile_subroutine_name()
    compile_first_token_for('subroutine_name')
  end

  def compile_subroutine_dec(opt = nil)
    return if (optional?(opt) && !starting_token_for?('subroutine_dec'))

    begin_terminal('subroutineDec')

    initialize_symbol_table_subroutine
    subroutine_type = @tokenizer.token
    # If method, first argument is the instance object
    if (subroutine_type == 'method' )
      @symbol_table.define({
        name: 'this',
        kind: 'ARG',
        type: @current_class_name
      })
    # If constructor, local variable is allocated for 'this'
    elsif (subroutine_type == 'constructor')
      @symbol_table.define({
        name: 'this',
        kind: 'VAR',
        type: @current_class_name
      })
    end

    compile_first_token_for('subroutine_dec')


    raise 'Expected (void || type)' if (!token_is?('void') && !starting_token_for?('type'))
    return_type = @tokenizer.token

    write_terminal_xml
    tokenizer.advance

    set_current_subroutine({
      name: @tokenizer.token,
      return_type: return_type,
      subroutine_type: subroutine_type,
    })

    compile_subroutine_name

    compile_token('(')
    compile_parameter_list
    compile_token(')')

    compile_subroutine_body

    end_terminal('subroutineDec')
    compile_subroutine_dec(opt) if repeat?(opt)
  end

  def compile_subroutine_body
    begin_terminal('subroutineBody')

    compile_first_token_for('subroutine_body')
    compile_var_dec('*')

    @vm_writer.write_function(
      "#{@current_class_name}.#{@current_subroutine[:name]}",
      @symbol_table.num_locals
    )

    # For constructor, we want to allocate memory for object in heap and set it to 'this'
    if (@current_subroutine[:subroutine_type] == 'constructor')
      this_segment = kind_to_segment_map(@symbol_table.kind_of('this'))
      this_index = @symbol_table.index_of('this')
      @vm_writer.write_push('constant', @symbol_table.var_count('FIELD'))
      @vm_writer.write_call('Memory.alloc', 1)
      @vm_writer.write_pop(this_segment, this_index)
      @vm_writer.write_push(this_segment, this_index)
      @vm_writer.write_pop('pointer', 0)
    elsif (@current_subroutine[:subroutine_type] == 'method')
      this_segment = kind_to_segment_map(@symbol_table.kind_of('this'))
      this_index = @symbol_table.index_of('this')
      @vm_writer.write_push(this_segment, this_index)
      @vm_writer.write_pop('pointer', 0)
    end

    compile_statements
    compile_token('}')

    end_terminal('subroutineBody')
  end

  def compile_parameter_list
    begin_terminal('parameterList')

    if (!starting_token_for?('parameter_list'))
      end_terminal('parameterList')
      return
    end

    compile_type_var_name('*')

    end_terminal('parameterList')
  end

  def compile_type_var_name(opt = nil)
    return if (optional?(opt) && !starting_token_for?('type_var_name'))

    type = compile_type
    compile_var_name(nil, { kind: 'ARG' , type: type })

    repeat_with_comma?(opt) do
      compile_type_var_name('+')
    end
  end

  def compile_var_dec(opt = nil)
    return if (optional?(opt) && !starting_token_for?('var_dec'))

    begin_terminal('varDec')

    compile_first_token_for('var_dec')
    type = compile_type
    compile_var_name('+', { kind: 'VAR', type: type })
    compile_token(';')

    end_terminal('varDec')

    compile_var_dec(opt) if repeat?(opt)
  end

  def compile_statements
    begin_terminal('statements')

    compile_statement('*')

    end_terminal('statements')
  end

  def compile_statement(opt = nil)
    if (starting_token_for?('if'))
      compile_if
    elsif (starting_token_for?('while'))
      compile_while
    elsif (starting_token_for?('do'))
      compile_do
    elsif (starting_token_for?('let'))
      compile_let
    elsif (starting_token_for?('return'))
      compile_return
    else
      return if repeat?(opt)
      raise 'Unexpected statement'
    end

    compile_statement('*') if repeat?(opt)

  end

  def compile_do
    begin_terminal('doStatement')

    compile_first_token_for('do')
    compile_subroutine_call
    compile_token(';')

    # do statement should not iterate stack. The returned
    # element is thrown away. Note that void subroutine also returns
    # a constant 0 by construction.
    @vm_writer.write_pop('temp', 0)

    end_terminal('doStatement')
  end

  def compile_let
    begin_terminal('letStatement')

    compile_first_token_for('let')

    var_name = @tokenizer.token
    var_segment = kind_to_segment_map(@symbol_table.kind_of(var_name))
    var_idx = @symbol_table.index_of(var_name)

    compile_var_name
    #  Case: Array
    if (token_is?('['))

      compile_token('[')
      compile_expression
      compile_token(']')

      @vm_writer.write_push(var_segment, var_idx)
      @vm_writer.write_arithmetic('add')
      @vm_writer.write_pop('temp', 1) # temporarily store (var_address + expression_output)

      compile_token('=')
      compile_expression
      compile_token(';')

      @vm_writer.write_pop('temp', 2)
      @vm_writer.write_push('temp', 1)
      @vm_writer.write_pop('pointer', 1)
      @vm_writer.write_push('temp', 2)
      @vm_writer.write_pop('that', 0) # *(var_address + expression_output) = right_hand_experssion
    #  Case: Non-array
    else
      compile_token('=')
      compile_expression
      compile_token(';')

      @vm_writer.write_pop(var_segment, var_idx)
    end
    end_terminal('letStatement')
  end

  def compile_while
    begin_terminal('whileStatement')

    start_label = @current_class_name + '_while_start_' + @while_loop_count.to_s
    end_label = @current_class_name + '_while_end_' + @while_loop_count.to_s
    @while_loop_count = @while_loop_count + 1

    @vm_writer.write_label(start_label)

    compile_first_token_for('while')
    compile_token('(')
    compile_expression
    compile_token(')')

    @vm_writer.write_arithmetic('not')
    @vm_writer.write_if(end_label)

    compile_token('{')
    compile_statements
    compile_token('}')

    @vm_writer.write_go_to(start_label)
    @vm_writer.write_label(end_label)

    end_terminal('whileStatement')
  end

  def compile_return
    begin_terminal('returnStatement')

    compile_first_token_for('return')
    compile_expression('?')
    compile_token(';')

    if (@current_subroutine[:return_type] == 'void')
      @vm_writer.write_push('constant', 0)
    end

    @vm_writer.write_return

    end_terminal('returnStatement')
  end

  def compile_if
    begin_terminal('ifStatement')

    else_label = @current_class_name + '_if_else_' + @if_loop_count.to_s
    end_label = @current_class_name + '_if_end_' + @if_loop_count.to_s
    @if_loop_count = @if_loop_count + 1

    compile_first_token_for('if')
    compile_token('(')
    compile_expression
    compile_token(')')

    @vm_writer.write_arithmetic('not')
    @vm_writer.write_if(else_label)

    compile_token('{')
    compile_statements
    compile_token('}')

    @vm_writer.write_go_to(end_label)
    @vm_writer.write_label(else_label)

    if (token_is?('else'))
      compile_token('else')
      compile_token('{')
      compile_statements
      compile_token('}')
    end

    @vm_writer.write_label(end_label)

    end_terminal('ifStatement')
  end

  def compile_expression(opt = nil)
    expression_count = 0
    return expression_count if (optional?(opt) && !starting_token_for?('expression'))

    begin_terminal('expression')

    compile_term

    repeat_with_op?('*') do |operator|
      compile_term

      if operator == '*'
        @vm_writer.write_call('Math.multiply', 2)
      elsif operator == '/'
        @vm_writer.write_call('Math.divide', 2)
      else
        @vm_writer.write_arithmetic(op_map(operator))
      end
    end

    repeat_with_comma?(opt) { expression_count = compile_expression('+') }

    end_terminal('expression')

    return expression_count + 1
  end

  def compile_expression_list
    begin_terminal('expressionList')

    expression_count = compile_expression('*')

    end_terminal('expressionList')

    return expression_count
  end

  def compile_term
    begin_terminal('term')

    # Case: unaryOp term
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if starting_token_for?('unary_op')
      op = @tokenizer.token

      compile_unary_op
      compile_term

      @vm_writer.write_arithmetic(unary_op_map(op))
    # Case: (expression)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elsif token_is?('(')
      compile_token('(')
      compile_expression
      compile_token(')')
    elsif token_type_is?(:IDENTIFIER)
      el_name = @tokenizer.token
      # Case: varName || varName[expression]
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if (@symbol_table.kind_of(el_name) != 'NONE')
        write_terminal_xml
        tokenizer.advance
        # Case: varName[expression]
        if token_is?('[')
          compile_token('[')
          compile_expression
          compile_token(']')

          @vm_writer.write_push(
            kind_to_segment_map(@symbol_table.kind_of(el_name)),
            @symbol_table.index_of(el_name)
          )
          @vm_writer.write_arithmetic('add') # (array_address + array_idx)
          @vm_writer.write_pop('pointer', 1) # set to base of that
          @vm_writer.write_push('that', 0) # *(array_address + array_idx)
        # Case: varName
        else
          @vm_writer.write_push(
            kind_to_segment_map(@symbol_table.kind_of(el_name)),
            @symbol_table.index_of(el_name)
          )
        end
      # Case: subroutineCall
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      else
        compile_subroutine_call
      end
    # Case: integerConstant
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elsif token_type_is?(:INTEGER)
      @vm_writer.write_push('constant', @tokenizer.token)
      compile_first_token_for('term')
    # Case: false
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elsif token_is?('false', 'null')
      @vm_writer.write_push('constant', 0)
      compile_first_token_for('term')
    # Case: true
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elsif token_is?('true')
      @vm_writer.write_push('constant', 0)
      @vm_writer.write_arithmetic('not')
      compile_first_token_for('term')
    # Case: this
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elsif token_is?('this')
      this_segment = kind_to_segment_map(@symbol_table.kind_of('this'))
      this_index = @symbol_table.index_of('this')
      @vm_writer.write_push(this_segment, this_index)

      compile_first_token_for('term')
    # Case: stringConstant
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    elsif token_type_is?(:STRING)
      str = @tokenizer.token
      @vm_writer.write_push('constant', str.size)
      @vm_writer.write_call('String.new', 1)

      str.each_char do |c|
        @vm_writer.write_push('constant', c.ord)
        @vm_writer.write_call('String.appendChar', 2)
      end

      compile_first_token_for('term')
    else
      compile_first_token_for('term')
    end

    end_terminal('term')
  end

  def compile_unary_op
    compile_first_token_for('unary_op')
  end

  def compile_op
    compile_first_token_for('op')
  end

  def compile_keyword_constant
    compile_first_token_for('keyword_constant')
  end

  def compile_subroutine_call
    el_name = @tokenizer.token
    arg_count = 0
    # Case: variable inside symbol table
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if @symbol_table.kind_of(el_name) != 'NONE'
      el_segment = kind_to_segment_map(@symbol_table.kind_of(el_name))
      el_index = @symbol_table.index_of(el_name)
      # push object base location as first argument
      @vm_writer.write_push(el_segment, el_index)

      compile_first_token_for('subroutine_call')
      compile_token('.')

      el_name = @symbol_table.type_of(el_name) + '.' + @tokenizer.token

      compile_subroutine_name
      compile_token('(')

      arg_count = compile_expression_list + 1

      compile_token(')')
    else
      compile_first_token_for('subroutine_call')
      # Case: method call inside another method
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if token_is?('(')
        el_name = @current_class_name + '.' + el_name

        this_segment = kind_to_segment_map(@symbol_table.kind_of('this'))
        this_index = @symbol_table.index_of('this')
        @vm_writer.write_push(this_segment, this_index)

        compile_token('(')

        arg_count = compile_expression_list + 1

        compile_token(')')
      # Case: class function call
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      else
        compile_token('.')

        el_name = el_name + '.' + @tokenizer.token

        compile_subroutine_name
        compile_token('(')

        arg_count = compile_expression_list

        compile_token(')')
      end
    end

    @vm_writer.write_call(el_name, arg_count)
  end

  private
  def write_terminal_xml
    if tokenizer.token == '<'
      xml_file.puts(
        "<#{tokenizer.token_type}> &lt </#{tokenizer.token_type}>"
      )
    elsif tokenizer.token == '>'
      xml_file.puts(
        "<#{tokenizer.token_type}> &gt </#{tokenizer.token_type}>"
      )
    elsif tokenizer.token == '&'
      xml_file.puts(
        "<#{tokenizer.token_type}> &amp </#{tokenizer.token_type}>"
      )
    else
      xml_file.puts(
        "<#{tokenizer.token_type}> #{tokenizer.token} </#{tokenizer.token_type}>"
      )
    end
  end

  def begin_terminal(tag_name)
    xml_file.puts("<#{tag_name}>")
  end

  def end_terminal(tag_name)
    xml_file.puts("</#{tag_name}>")
  end

  def compile_token(token)
    if (!token_is?(token))
      raise "Expected '#{token}' to be the next token"
    end

    write_terminal_xml
    tokenizer.advance
  end

  def compile_first_token_for(element)
    if !starting_token_for?(element)
      raise "Unexpected first token for #{element} element"
    end

    write_terminal_xml
    tokenizer.advance
  end

  # options for zero or one or more
  def repeat?(opt = nil)
    ['*', '+'].include?(opt)
  end

  def repeat_with_comma?(opt = nil)
    if(repeat?(opt) && token_is?(','))
      write_terminal_xml
      tokenizer.advance

      yield
    end
  end

  def repeat_with_op?(opt = nil)
    if(repeat?(opt) && starting_token_for?('op'))
      operator = @tokenizer.token
      write_terminal_xml
      tokenizer.advance

      yield(operator)
    end
  end

  def optional?(opt = nil)
    ['*', '?'].include?(opt)
  end

  def token_is?(*args)
    args.include?(tokenizer.token)
  end

  def token_type_is?(key)
    tokenizer.token_type == terminal(key)
  end

  def keyword(key)
    JackTokenizer::KEYWORD[key]
  end

  def terminal(key)
    JackTokenizer::TERMINAL[key]
  end

  def starting_token_for?(element)
    case (element)
    when 'class'
      token_is?('class')
    when 'class_var_dec'
      token_is?('field', 'static')
    when 'type'
      token_is?('int', 'char', 'boolean') || token_type_is?(:IDENTIFIER)
    when 'class_name'
      token_type_is?(:IDENTIFIER)
    when 'var_name'
      token_type_is?(:IDENTIFIER)
    when 'subroutine_name'
      token_type_is?(:IDENTIFIER)
    when 'subroutine_dec'
      token_is?('constructor', 'function', 'method')
    when 'subroutine_body'
      token_is?('{')
    when 'parameter_list'
      starting_token_for?('type')
    when 'type_var_name'
      starting_token_for?('type')
    when 'var_dec'
      token_is?('var')
    when 'let'
      token_is?('let')
    when 'if'
      token_is?('if')
    when 'while'
      token_is?('while')
    when 'do'
      token_is?('do')
    when 'return'
      token_is?('return')
    when 'term'
      token_type_is?(:INTEGER) ||
      token_type_is?(:STRING) ||
      starting_token_for?('keyword_constant') ||
      starting_token_for?('var_name') ||
      starting_token_for?('subroutine_call') ||
      token_is?('(') ||
      starting_token_for?('unary_op')
    when 'op'
      token_is?('+', '-', '*', '/', '&', '|', '<', '>', '=')
    when 'unary_op'
      token_is?('-', '~')
    when 'keyword_constant'
      token_is?('true', 'false', 'null', 'this')
    when 'expression'
      starting_token_for?('term')
    when 'expression_list'
      starting_token_for?('expression')
    when 'subroutine_call'
      starting_token_for?('subroutine_name') ||
      starting_token_for?('class_name') ||
      starting_token_for?('var_name')
    end
  end

  def set_current_class_name
    @current_class_name = @tokenizer.token
  end

  def set_current_subroutine(name:, return_type:, subroutine_type:)
    @current_subroutine = {
      name: name,
      return_type: return_type,
      subroutine_type: subroutine_type
    }
  end

  def initialize_symbol_table_subroutine()
    @symbol_table.start_subroutine
  end

  def define_in_symbol_table(data)
    @symbol_table.define(data)
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

  def kind_to_segment_map(kind)
    {
     'STATIC' => 'static',
      'FIELD' => 'this',
      'ARG' => 'argument',
      'VAR' => 'local',
    }[kind]
  end

  def declarator_to_kind_map(d)
    {
      'static' => 'STATIC',
      'field' => 'FIELD',
      'var' => 'VAR',
    }[d]
  end
end