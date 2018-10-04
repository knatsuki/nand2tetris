class ASMParser
  def initialize(file)
    @file = file
    @current_line = @file.gets
    @line_number = 0
  end

  def has_more_commands
    return true if @current_line
    false
  end

  def current_line
    return nil if @current_line.nil?

    @current_line.gsub(/\s*\/\/.*/, '').strip # Filter out comments (// comments...)
  end

  def line_number
    @line_number
  end

  def advance
    # iterates current line to the next one
    @current_line = @file.gets

    # @line_number is not iterated for comments and labels
    if has_more_commands && ['A_COMMAND', 'C_COMMAND'].include?(command_type)
      @line_number = @line_number + 1
    end
  end

  def rewind
    @file.rewind
    @current_line = @file.gets
    @line_number = 0
  end

  def command_type
    if current_line.length == 0
      'COMMENT'
    elsif current_line[/\(([^\)]+)\)/]
      'L_COMMAND'
    elsif current_line[/@([^@].*)/]
      'A_COMMAND'
    else
      'C_COMMAND'
    end
  end

  def symbol
    # "@xxx" or "(xxx)" -> "xxx"
    current_line[/\(([^\)]+)\)/, 1] || current_line[/@([^@].*)/, 1]
  end

  def dest
    # "dest=comp;jump" -> "dest"
    current_line[/(\w+)=/, 1]
  end

  def comp
    # "dest=comp;jump" -> "comp"
    current_line[/\w*=?([^;]+);?/, 1]
  end

  def jump
    # "dest=comp;jump" -> "jump"
    current_line[/;(.+)/, 1]
  end
end
