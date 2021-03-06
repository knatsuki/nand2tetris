require_relative 'asm_code'
require_relative 'asm_parser'
require_relative 'asm_symbol_table'

module ASMAssember
  def self.run(file_path)
    begin
      # In: (file_path: str)
      # Out: (output: File)
      file = File.open(file_path)
      parser = ASMParser.new(file)
      symbol_table = ASMSymbolTable.new

      output_file_path = file_path[/(.+).asm/, 1] + '.hack'
      output_file = File.new(output_file_path, 'w+')

      while parser.has_more_commands
        if parser.command_type == 'L_COMMAND'
          symbol_table.add_label(parser.symbol, parser.line_number)
        end

        parser.advance
      end

      parser.rewind

      while parser.has_more_commands
        if parser.command_type == 'A_COMMAND'
          sym = parser.symbol
          unless symbol_table.contains(sym)
            symbol_table.add_address(sym)
          end
          # puts symbol_table.instance_variable_get(:@table)
          command = '0' + symbol_table.get_address(sym)
          output_file.puts(command)

        elsif parser.command_type == 'C_COMMAND'
          command = '111' + ASMCode.comp(parser.comp) + ASMCode.dest(parser.dest) + ASMCode.jump(parser.jump)
          output_file.puts(command)
        end

        parser.advance
      end

      file.close
      output_file.close

      puts "File saved to '#{output_file_path}'"
    rescue StandardError => e
      file.close if file
      File.delete(output_file_path) if output_file
      puts(e.message)
      puts(e.backtrace.inspect)
      puts 'Aborted... Problem encountered while assembling'
    end
  end
end
