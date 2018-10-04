require_relative './jack_compiler'
require_relative './vm_translator'
require_relative './asm_assember'

desc "Compile .jack codes to .vm codes"
task :jack_compile do
  if ARGV.size < 2
    puts 'Exiting... File directory must be included as argument.'
    exit
  end

  file_directory = ARGV[1]
  puts "The directory you entered: \"#{file_directory}\""

  JackCompiler.run(file_directory)
end

desc "Translate .vm files to single .asm assembly code file"
task :vm_translate do
  if ARGV.size < 2
    puts 'Exiting... File path must be included as argument.'
    exit
  end

  file_name = ARGV[1]
  puts "The file you entered: \"#{file_name}\""

  VMTranslator.run(file_name)
end

desc "Assemble .asm assembly code file to .hack machine language code file"
task :asm_assemble do
  if ARGV.size < 2
    puts 'Exiting... File path must be included as argument.'
    exit
  end

  file_name = ARGV[1]
  puts "The file you entered: \"#{file_name}\""

  ASMAssember.run(file_name)
end