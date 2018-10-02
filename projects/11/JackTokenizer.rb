# Parse content of Jack file into atomic terminal elements
class JackTokenizer
  KEYWORD_REGEX = /\A(?:class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return)\z/
  SYMBOL_REGEX = /[\{\}\(\)\[\]\.\,\;\+\-\*\/\&\|\<\>\=\~]/
  # INTEGER_CONSTANT_REGEX = /\A[1-9]\d+\z/
  # STRING_CONSTANT_REGEX = /\A\"(.*?)\"\z/
  # IDENTIFIER_REGEX = /\A[_a-zA-Z]\w*/
  QUOTE_REGEX = /\"/
  DIGIT_REGEX = /[0-9]/
  NON_ZERO_DIGIT_REGEX = /[1-9]/
  WORD_REGEX = /\w/
  NON_DIGIT_WORD_REGEX = /[_a-zA-Z]/
  COMMENTS_REGEX = /\/\/.*\n|(?m)\/\*.*?\*\//
  WHITESPACE_REGEX = /\s/

  TERMINAL = {
    :KEYWORD => 'keyword',
    :SYMBOL => 'symbol',
    :STRING => 'stringConstant',
    :INTEGER => 'integerConstant',
    :IDENTIFIER => 'identifier',
  }

  KEYWORD = {
    :class => 'class',
    :constructor => 'constructor',
    :function => 'function',
    :method => 'method',
    :field => 'field',
    :static => 'static',
    :var => 'var',
    :int => 'int',
    :char => 'char',
    :boolean => 'boolean',
    :void => 'void',
    :true => 'true',
    :false => 'false',
    :null => 'null',
    :this => 'this',
    :let => 'let',
    :do => 'do',
    :if => 'if',
    :else => 'else',
    :while => 'while',
    :return => 'return',
  }

  def initialize(file_texts)
    @remaining_characters = file_texts.gsub(COMMENTS_REGEX, '').strip
    @token = ''
    @token_type = nil
  end

  def token
    @token
  end

  def has_more_token?
    @remaining_characters.size > 0
  end

  def advance
    @token = ''

    if !has_more_token? 
      @token_type = nil
      return
    end
    
    # mine until first non-whitespace character is found
    mining = true
    while (mining)
      rnc = retrieve_next_character

      if (!!rnc[WHITESPACE_REGEX]) # skip any whitespace character
        next 
      else
        token << rnc
        mining = false
      end
    end

    if (token[SYMBOL_REGEX])
      @token_type = TERMINAL[:SYMBOL]
    elsif token[DIGIT_REGEX]
      if token[/0/]
        inc = inspect_next_character        
        if (inc[WHITESPACE_REGEX] || inc[SYMBOL_REGEX])
          @token_type = TERMINAL[:INTEGER]
          mining = false
        else
          raise 'invalid numeric constant'
        end
      else
        mining = true
        while (mining)
          inc = inspect_next_character
          if (inc[DIGIT_REGEX])
            token << retrieve_next_character
          elsif (inc[WHITESPACE_REGEX] || inc[SYMBOL_REGEX])
            @token_type = TERMINAL[:INTEGER]
            mining = false
          else
            raise 'invalid numeric constant'
          end
        end        
      end
    elsif token[QUOTE_REGEX]
      mining = true
      while (mining)
        rnc = retrieve_next_character
        token << rnc
        if (rnc[QUOTE_REGEX])
          @token_type = TERMINAL[:STRING]
          mining = false
        end
      end
    elsif token[NON_DIGIT_WORD_REGEX]
      mining = true
      while (mining)
        inc = inspect_next_character

        if (!inc[WORD_REGEX])
          if(token[KEYWORD_REGEX])
            @token_type = TERMINAL[:KEYWORD]
          else
            @token_type = TERMINAL[:IDENTIFIER]
          end
          mining = false
        else
          rnc = retrieve_next_character
          token << rnc          
        end
      end
    end
  end

  def token_type
    @token_type
  end

  private

  def retrieve_next_character
    @remaining_characters.slice!(0)
  end

  def inspect_next_character
    @remaining_characters[0]
  end
end