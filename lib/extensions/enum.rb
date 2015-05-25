module ActiveRecord
  module ConnectionAdapters
    
    class TableDefinition
      def enum(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'enum', options) }
      end
    end
    
    module SchemaStatements
      # Add enumeration support for schema statement creation. This
      # will have to be adapted for every adapter if the type requires
      # anything by a list of allowed values. The overrides the standard
      # type_to_sql method and chains back to the default. This could 
      # be done on a per adapter basis, but is generalized here.
      #
      # will generate enum('a', 'b', 'c') for :limit => [:a, :b, :c]
      def type_to_sql(type, limit = nil, precision = nil, scale = nil) #:nodoc:
        if type == :enum
          native = native_database_types[type]
          column_type_sql = (native || {})[:name] || 'enum'

          column_type_sql << "(#{limit.map { |v| ActiveRecord::Base.send(:quote_bound_value, v.to_s) }.join(',')})"

          column_type_sql
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.module_eval do

  def native_database_types #:nodoc
    types = __native_database_types_enum
    types[:enum] = { :name => "enum" }
    types
  end
  
  alias __native_database_types_enum native_database_types
end

ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::Column.module_eval do

  # The class for enum is Symbol.
  def klass
    if type == :enum
      Symbol
    end
  end

  # Convert to a symbol.
  def type_cast(value)
    if type == :enum
      self.class.value_to_symbol(value)
    end
  end

  if respond_to?(:type_cast_code)

    # Code to convert to a symbol.
    def type_cast_code(var_name)
      if type == :enum
        "#{self.class.name}.value_to_symbol(#{var_name})"
      end
    end
  end

  class << self
    # Safely convert the value to a symbol.
    def value_to_symbol(value)
      case value
      when Symbol
        value
      when String
        value.empty? ? nil : value.intern
      else
        nil
      end
    end
  end

  private
  # The enum simple type.
  def simplified_type(field_type)
    if field_type =~ /enum/i
      :enum
    end
  end
  
  def extract_limit(sql_type)
    if sql_type =~ /^enum/i
      sql_type.sub(/^enum\('(.+)'\)/i, '\1').split("','").map { |v| v.intern }
    end
  end
end