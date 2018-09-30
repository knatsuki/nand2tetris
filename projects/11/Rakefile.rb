require_relative './JackAnalyzer'

desc "Compile .jack files"
task :compile do
  if ARGV.size < 2
    puts 'Exiting... File directory must be included as argument.'
    exit
  end

  file_directory = ARGV[1]
  puts "The directory you entered: \"#{file_directory}\""

  JackAnalyzer.run(file_directory)
end