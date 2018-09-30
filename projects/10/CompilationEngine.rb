require_relative './JackTokenizer'

class CompilationEngine 
  def initialize(file_texts:, write_file:)
    @tokenizer = JackTokenizer.new(file_texts)
    @write_file = write_file

    tokenizer.advance

    compile_class
  end

  def tokenizer
    @tokenizer
  end

  def write_file
    @write_file
  end

  def compile_class
    write_non_terminal_begin_xml('class')

    compile_first_token_for('class')
    compile_class_name
    compile_token('{')    
    compile_class_var_dec('*')
    compile_subroutine_dec('*')
    compile_token('}')

    write_non_terminal_end_xml('class')
  end

  def compile_class_var_dec(opt = nil)
    return if (optional?(opt) && !starting_token_for?('class_var_dec'))
    
    write_non_terminal_begin_xml('classVarDec')

    compile_first_token_for('class_var_dec')
    compile_type
    compile_var_name('+')

    write_non_terminal_end_xml('classVarDec')

    if (repeat?(opt) && starting_token_for?('class_var_dec')) 
        compile_class_var_dec(opt)
    end
  end

  def compile_type
    compile_first_token_for('type')
  end

  def compile_class_name(opt = nil)
    return if (optional?(opt) && !starting_token_for?('class_name'))

    compile_first_token_for('class_name')
  end

  def compile_var_name(opt = nil)
    return if (optional?(opt) && !starting_token_for?('var_name'))

    compile_first_token_for('var_name')

    repeat_with_comma?(opt) { compile_var_name('+') }
  end

  def compile_subroutine_name()
    compile_first_token_for('subroutine_name')
  end

  def compile_subroutine_dec(opt = nil)
    return if (optional?(opt) && !starting_token_for?('subroutine_dec'))

    write_non_terminal_begin_xml('subroutineDec')

    compile_first_token_for('subroutine_dec')

    if (!token_is?('void') && !starting_token_for?(type)) 
      raise 'Expected (void || type)'
    end

    write_terminal_xml
    tokenizer.advance

    compile_subroutine_name
    compile_token('(')
    compile_parameter_list
    compile_token(')')
    compile_subroutine_body

    write_non_terminal_end_xml('subroutineDec')

    repeat_with_comma?(opt) { compile_subroutine_dec('+') }
  end

  def compile_subroutine_body
    write_non_terminal_begin_xml('subroutineBody')

    compile_first_token_for('subroutine_body')
    compile_var_dec('*')
    compile_statements
    compile_token('}')

    write_non_terminal_end_xml('subroutineBody')
  end

  def compile_parameter_list
    write_non_terminal_begin_xml('parameterList')
    
    if (!starting_token_for?('parameter_list')) 
      write_non_terminal_end_xml('parameterList')
      return
    end

    compile_type_var_name('*')

    write_non_terminal_end_xml('parameterList')
  end

  def compile_type_var_name(opt = nil)
    return if (optional?(opt) && !starting_token_for?('type_var_name'))

    compile_type
    compile_var_name    

    repeat_with_comma?(opt) do 
      compile_type_var_name('+')
    end
  end

  def compile_var_dec(opt = nil)
    return if (optional?(opt) && !starting_token_for?('var_dec'))

    write_non_terminal_begin_xml('varDec')

    compile_first_token_for('var_dec')
    compile_type
    compile_var_name('+')
    compile_token(';')

    write_non_terminal_end_xml('varDec')

    compile_var_dec(opt) if repeat?(opt) 
  end

  def compile_statements
    write_non_terminal_begin_xml('statements')

    compile_statement('*')

    write_non_terminal_end_xml('statements')
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
    write_non_terminal_begin_xml('doStatement')

    compile_first_token_for('do')
    compile_subroutine_call
    compile_token(';')

    write_non_terminal_end_xml('doStatement')
  end

  def compile_let
    write_non_terminal_begin_xml('letStatement')

    compile_first_token_for('let')
    compile_var_name

    if (token_is?('['))
      compile_token('[')
      compile_expression
      compile_token(']')
    end

    compile_token('=')
    compile_expression
    compile_token(';')

    write_non_terminal_end_xml('letStatement')
  end

  def compile_while
    write_non_terminal_begin_xml('whileStatement')

    compile_first_token_for('while')
    compile_token('(')
    compile_expression
    compile_token(')')
    compile_token('{')
    compile_statements
    compile_token('}')

    write_non_terminal_end_xml('whileStatement')
  end

  def compile_return
    write_non_terminal_begin_xml('returnStatement')

    compile_first_token_for('return')    
    compile_expression('?')
    compile_token(';')

    write_non_terminal_end_xml('returnStatement')
  end

  def compile_if
    write_non_terminal_begin_xml('ifStatement')

    compile_first_token_for('if')
    compile_token('(')
    compile_expression
    compile_token(')')
    compile_token('{')
    compile_statements
    compile_token('}')

    if (token_is?('else')) 
      compile_token('else')
      compile_token('{')
      compile_statements
      compile_token('}')
    end

    write_non_terminal_end_xml('ifStatement')
  end

  def compile_expression(opt = nil)
    return if (optional?(opt) && !starting_token_for?('expression'))

    write_non_terminal_begin_xml('expression')

    compile_term

    repeat_with_op?('*') { compile_term }

    repeat_with_comma?(opt) { compile_expression('+') } 

    write_non_terminal_end_xml('expression')

  end

  def compile_expression_list
    write_non_terminal_begin_xml('expressionList')

    compile_expression('*')

    write_non_terminal_end_xml('expressionList')
  end

  def compile_term
    write_non_terminal_begin_xml('term')

    if starting_token_for?('unary_op')
      compile_unary_op
      compile_term
    elsif token_is?('(')
      compile_token('(')
      compile_expression
      compile_token(')')
    elsif token_type_is?(:IDENTIFIER)
      write_terminal_xml
      tokenizer.advance

      if token_is?('[')
        compile_token('[')
        compile_expression
        compile_token(']')
      end

      if token_is?('.')
        compile_token('.')
        compile_subroutine_name
        compile_token('(')
        compile_expression_list
        compile_token(')')
      elsif token_is?('(')
        compile_token('(')
        compile_expression_list
        compile_token(')')        
      end
    else
      compile_first_token_for('term')
    end

    write_non_terminal_end_xml('term')
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
    compile_first_token_for('subroutine_call')

    if token_is?('(')
      compile_token('(')
      compile_expression_list
      compile_token(')')
    else       
    compile_token('.')
    compile_subroutine_name
    compile_token('(')
    compile_expression_list
    compile_token(')')
    end
  end

  private
  def write_terminal_xml
    if tokenizer.token == '<'
      write_file.puts(
        "<#{tokenizer.token_type}> &lt </#{tokenizer.token_type}>" 
      )
    elsif tokenizer.token == '>'
      write_file.puts(
        "<#{tokenizer.token_type}> &gt </#{tokenizer.token_type}>" 
      )
    elsif tokenizer.token == '&'
      write_file.puts(
        "<#{tokenizer.token_type}> &amp </#{tokenizer.token_type}>" 
      )
    else
      write_file.puts(
        "<#{tokenizer.token_type}> #{tokenizer.token} </#{tokenizer.token_type}>" 
      )
    end
  end

  def write_non_terminal_begin_xml(tag_name)
    write_file.puts("<#{tag_name}>")
  end

  def write_non_terminal_end_xml(tag_name)
    write_file.puts("</#{tag_name}>")
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
      write_terminal_xml
      tokenizer.advance

      yield
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
end