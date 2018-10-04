require_relative 'CompilationEngine'

module JackAnalyzer
  def self.run(file_directory)
    begin
      jack_file_paths = Dir[file_directory + '/*.jack']
      output_file_path = nil
      output_file = nil

      jack_file_paths.each do |jack_file_path|
        # open input file
        jack_file_string = File.read(jack_file_path)
        # create output file
        output_file_path_1 = jack_file_path[/(.+).jack/].gsub(/.jack/, '') + 'Analyzed' + '.xml'
        output_file_path_2 = jack_file_path[/(.+).jack/].gsub(/.jack/, '') + '.vm'
        output_file_1 = File.new(output_file_path_1, 'w+')
        output_file_2 = File.new(output_file_path_2, 'w+')
        CompilationEngine.new(
          file_texts: jack_file_string,
          xml_file: output_file_1,
          vm_file: output_file_2,
        )

        output_file_1.close
        output_file_2.close
      end

    rescue StandardError => e
      # File.delete(output_file_path) if output_file
      puts(e.message)
      puts(e.backtrace.inspect)
      puts 'Aborted... Problem encountered while analyzing'
    end
  end
end