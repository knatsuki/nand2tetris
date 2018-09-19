# Parse content of Jack file into atomic terminal elements
class JackTokenizer
  KEYWORD_REGEX = /\A(?:class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)\z/
  SYMBOL_REGEX = /\A[\{\}\(\)\[\]\.\,\;\+\-\*\/\&\|\<\>\=\~]\z/
  INTEGER_CONSTANT_REGEX = /\A[1-9]\d+\z/
  STRING_CONSTANT_REGEX = /\A\"(.*?)\"\z/
  IDENTIFIER_REGEX = /\A[_a-zA-Z]\w*/
  COMMENTS_REGEX = /\/\/.*\n|\/\*.*?\*\//
  WHITESPACE_REGEX = /\s/

  def initializer(file_texts)
    @unparsed_texts = file_texts.gsub(COMMENTS_REGEX, '').strip
    @current_token = nil
  end

  def current_token
    @current_token
  end

  def has_more_token?
    @file_texts.size > 0
  end

  def advance
    @current_token.clear
    keep_iterating = true
    while(keep_iterating)
      append_to_current_token

      if symbol_terminal?
        keep_iterating = false
      elsif integer_terminal?
        keep_iterating = false
      elsif string_terminal?
        keep_iterating = false
      elsif keyword_terminal?
        keep_iterating = false
      elsif identifier_terminal?
        keep_iterating = false
      end        
    end
  end

  def token_type

  end

  private

  def append_to_current_token
    @current_token << @unparsed_texts.slice!(0)
  end

  def next_char_is_word_character?
    @unparsed_texts[0][/\w/]
  end

  def keyword_terminal?
    !!current_token[KEYWORD_REGEX] && !next_char_is_word_character?
  end

  def symbol_terminal?
    current_token.size  == 0 && !!current_token[SYMBOL_REGEX]
  end

  def integer_terminal?
    !!current_token[INTEGER_CONSTANT_REGEX]
  end

  def string_terminal?
    !!current_token[STRING_CONSTANT_REGEX]
  end

  def identifier_terminal?
    !!current_token[IDENTIFIER_REGEX] && 
    !current_token[KEYWORD_REGEX] && 
    !next_char_is_word_character?
  end



  # File-related methods
  # ~~~~~~~~~~~~~~~~~~~~

  def end_of_file_stream?
    @current_line.nil?
  end

  def clean_up_yo_line(str)

  end
end