class Hash
  def compact
    delete_if { |k, v| v.nil? }
  end
end

class Array
  def only( *keys )
    map do |hash|
      hash.select do |key, value|
        keys.map{ |symbol| symbol.to_s }.include? key.to_s
      end
    end
  end
end
