# Reads a VM file line by line. Responsible for identifying the command type for each command
# line and provides API to access the command argument
class Parser
  COMMAND_TYPES = {
    :NO_MORE_COMMANDS => 'NO_MORE_COMMANDS',
    :COMMENT => 'COMMENT',
    :C_PUSH => 'C_PUSH',
    :C_POP => 'C_POP',
    :C_ARITHMETIC => 'C_ARITHMETIC',
  }

  def initialize(file)
    @file = file
    @current_command = file.gets
  end

  def current_command
  # getter for @current_command that removes comments
  return nil if @current_command.nil?

  @current_command.gsub(/\s*\/\/.*/, '').strip # Filter out comments (// comments...)
  end

  def has_more_commands?
    # returns true if more commands exists in file stream
    !current_command.nil?    
  end

  def advance
    # iterates file stream to next command
    @current_command = @file.gets
  end

  def command_type
    # returns the type of the current VM command
    if current_command.nil?
      return COMMAND_TYPES[:NO_MORE_COMMANDS]
    elsif current_command.length == 0
      return COMMAND_TYPES[:COMMENT]
    elsif current_command[/push/]
      return COMMAND_TYPES[:C_PUSH]
    elsif current_command[/pop/]
      return COMMAND_TYPES[:C_POP]
    else
      return COMMAND_TYPES[:C_ARITHMETIC]
    end
  end

  def arg1
    # returns first argument of current command
    if command_type == COMMAND_TYPES[:C_ARITHMETIC]
      return current_command
    elsif command_type == COMMAND_TYPES[:C_PUSH]
      return current_command[/push\s(\D+)\s(\d+)/, 1]
    elsif command_type == COMMAND_TYPES[:C_POP]
      return current_command[/pop\s(\D+)\s(\d+)/, 1]
    end

    raise 'Incompatible method for command type'
  end

  def arg2
    # returns second argument of current command
    if command_type == COMMAND_TYPES[:C_PUSH]
      return current_command[/push\s(\D+)\s(\d+)/, 2].to_i
    elsif command_type == COMMAND_TYPES[:C_POP]
      return current_command[/pop\s(\D+)\s(\d+)/, 2].to_i
    end

    raise 'Incompatible method for command type'
  end
end