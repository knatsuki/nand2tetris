require_relative './vm_parser'
require_relative './vm_code_writer'

module VMTranslator
  def self.run(file_directory)
    begin
      # Create 'file_directory/file_directory.asm' file
      child_directory_name = file_directory[/.*\/(.+)/, 1]
      output_file_path = file_directory + '/' + child_directory_name + '.asm'
      output_file = File.new(output_file_path, 'w+')
      # Instantiate a CodeWriter instance with the created file
      code_writer = VMCodeWriter.new(output_file)
      # Find all *.vm files in directory. Iterate through them.
      vm_file_paths = Dir[file_directory + '/*.vm']

      #initialize with bootstrap code if more than one file
      if vm_file_paths.size > 1
        code_writer.write_init
      end

      vm_file = nil
      vm_file_paths.each do |vm_file_path|
        vm_file = File.open(vm_file_path)
        #   Create a Parser instance with a
        parser = VMParser.new(vm_file)
        #   Call #set_file_name for the provided a.vm (used by static segment)
        vm_file_name = vm_file_path[/.*\/(.+).vm/,1]
        code_writer.set_file_name(vm_file_name)

        while parser.has_more_commands?
          if parser.command_type == VMParser::COMMAND_TYPES[:C_PUSH]
            code_writer.write_push(parser.arg1, parser.arg2)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_POP]
            code_writer.write_pop(parser.arg1, parser.arg2)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_ARITHMETIC]
            code_writer.write_arithmetic(parser.arg1)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_LABEL]
            code_writer.write_label(parser.arg1)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_GOTO]
            code_writer.write_goto(parser.arg1)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_IF_GOTO]
            code_writer.write_if_goto(parser.arg1)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_FUNCTION]
            code_writer.write_function(parser.arg1, parser.arg2)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_CALL]
            code_writer.write_call(parser.arg1, parser.arg2)
          elsif parser.command_type == VMParser::COMMAND_TYPES[:C_RETURN]
            code_writer.write_return
          end

          parser.advance
        end

        vm_file.close
      end

      # Close CodeWriter instance
      code_writer.close
      puts 'File succesfully saved: "' + output_file_path + '"'

    rescue StandardError => e
      vm_file.close if vm_file
      File.delete(output_file_path) if output_file
      puts(e.message)
      puts(e.backtrace.inspect)
      puts 'Aborted... Problem encountered while translating'
    end
  end
end