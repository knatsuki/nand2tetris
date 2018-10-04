class SymbolTable
  KIND = {
    :STATIC => 'STATIC',
    :FIELD => 'FIELD',
    :ARG => 'ARG',
    :VAR => 'VAR',
  }

  # Hash structure for each symbol
  # {
  #   name: {
  #     type:
  #     kind:
  #     number:
  #   },
  #   ...
  # }

  def initialize
    @static_symbols = {}
    @field_symbols = {}
    @arg_symbols = {}
    @var_symbols = {}
  end

  def start_subroutine
    # Start a new subroutine scope
    @arg_symbols.clear
    @var_symbols.clear
  end

  def define(name:, type:, kind:)
    # Define a new idenfitifer of a given name, type and kind. 
    # Assign it a running index
    # STATIC/FIELD idenitifers have a class scope
    # ARG/VAR identifers have a subroutine scope
    if (kind == KIND[:STATIC])
      @static_symbols[name] = define_symbol(type, kind, var_count(kind))
    elsif (kind == KIND[:FIELD])
      @field_symbols[name] = define_symbol(type, kind, var_count(kind))
    elsif (kind == KIND[:ARG])
      @arg_symbols[name] = define_symbol(type, kind, var_count(kind))
    elsif (kind == KIND[:VAR])
      @var_symbols[name] = define_symbol(type, kind, var_count(kind))
    else
      throw 'Unrecognized kind for defined symbol'
    end


  end

  def var_count(kind)
    # Returns the numbers of variables of the given kind already defined in the current scope
    if (kind == KIND[:STATIC])
      @static_symbols.keys.count
    elsif (kind == KIND[:FIELD])
      @field_symbols.keys.count
    elsif (kind == KIND[:ARG])
      @arg_symbols.keys.count
    elsif (kind == KIND[:VAR])
      @var_symbols.keys.count
    else
      throw 'Unrecognized kind for defined symbol'
    end
  end

  def kind_of(name)
    # Returns the kind of the named identifier in the current scope.
    # If identifier is unknown in the current scope, returns NONE
    return 'NONE' unless all_symbols[name]
    
    all_symbols[name][:kind]
  end

  def type_of(name)
    # Returns the type of the named identifier in the current scope
    all_symbols[name][:type]
  end

  def index_of(name)
    # Returns the index assigned to the named identifier
    all_symbols[name][:index]
  end

  def num_locals
    var_count(KIND[:VAR])
  end

  private
  def define_symbol(type, kind, index)
    { type: type, kind: kind, index: index }
  end

  def all_symbols
    @static_symbols.merge(@field_symbols).merge(@arg_symbols).merge(@var_symbols)
  end
end