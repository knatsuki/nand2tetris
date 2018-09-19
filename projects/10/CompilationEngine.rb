require_relative './JackTokenizer'

class CompilationEngine 
  def initializer(read_file:, write_file:)
    @tokenizer = JackTokenizer.new(read_file)
    @write_file = write_file
    @parse_tree = nil #some tree-like data structure
  end

  def compile_class
    
  end
end