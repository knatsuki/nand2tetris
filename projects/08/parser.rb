# Reads a VM file line by line. Responsible for identifying the command type for each command
# line and provides API to access the command argument
class Parser
  COMMAND_TYPES = {
    :NO_MORE_COMMANDS => 'NO_MORE_COMMANDS',
    :COMMENT => 'COMMENT',
    :C_PUSH => 'C_PUSH',
    :C_POP => 'C_POP',
    :C_LABEL => 'C_LABEL',
    :C_GOTO => 'C_GOTO',
    :C_IF_GOTO => 'C_IF_GOTO',
    :C_FUNCTION => 'C_FUNCTION',
    :C_CALL => 'C_CALL',
    :C_RETURN => 'C_RETURN',
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
    elsif current_command[/label/]
      return COMMAND_TYPES[:C_LABEL]
    elsif current_command[/if-goto/] 
      # Note: if-goto flow must be checked before goto flow with this regex
      return COMMAND_TYPES[:C_IF_GOTO]
    elsif current_command[/goto/]
      return COMMAND_TYPES[:C_GOTO]
    elsif current_command[/call/]
      return COMMAND_TYPES[:C_CALL]
    elsif current_command[/return/]
      return COMMAND_TYPES[:C_RETURN]
    elsif current_command[/function/]
      return COMMAND_TYPES[:C_FUNCTION]
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
    elsif command_type == COMMAND_TYPES[:C_LABEL]
      return current_command[/label\s(.+)/, 1]
    elsif command_type == COMMAND_TYPES[:C_IF_GOTO]
      return current_command[/if-goto\s(.+)/, 1]
    elsif command_type == COMMAND_TYPES[:C_GOTO]
      return current_command[/goto\s(.+)/, 1]
    elsif command_type == COMMAND_TYPES[:C_CALL]
      return current_command[/call\s(.+)\s(\d+)/, 1]
    elsif command_type == COMMAND_TYPES[:C_FUNCTION]
      return current_command[/function\s(.+)\s(\d+)/, 1]
    end

    raise 'Incompatible method for command type'
  end

  def arg2
    # returns second argument of current command
    if command_type == COMMAND_TYPES[:C_PUSH]
      return current_command[/push\s(\D+)\s(\d+)/, 2].to_i
    elsif command_type == COMMAND_TYPES[:C_POP]
      return current_command[/pop\s(\D+)\s(\d+)/, 2].to_i
    elsif command_type == COMMAND_TYPES[:C_CALL]
      return current_command[/call\s(.+)\s(\d+)/, 2].to_i
    elsif command_type == COMMAND_TYPES[:C_FUNCTION]
      return current_command[/function\s(.+)\s(\d+)/, 2].to_i
    end

    raise 'Incompatible method for command type'
  end
end