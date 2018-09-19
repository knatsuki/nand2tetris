require_relative 'CompilationEngine'

module JackAnalyzer
  def self.run(file_directory)
    begin
      jack_file_paths = Dir[file_directory + '/*.jack']

      jack_file_paths.each do |jack_file_path|
        # open input file
        jack_file_string = File.read(jack_file_path, 'w+')
        # create output file
        output_file_path = jack_file_path[/(.+).jack/] + '.xml'
        output_file = File.new(output_file_path)

        CompilationEngine.new(
          read_file: jack_file_string,
          write_file: output_file,
        )

        output_file.close
      end

    rescue StandardError => e
      File.delete(output_file_path) if output_file
      puts(e.message)
      puts(e.backtrace.inspect)
      puts 'Aborted... Problem encountered while analyzing'
    end
  end
end