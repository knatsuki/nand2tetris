require_relative './main'

task :assemble do
  if ARGV.size < 2
    puts 'Exiting... File path must be included as argument.'
    exit
  end

  file_name = ARGV[1]
  puts "The file you entered: \"#{file_name}\""

  Main.run(file_name)
end