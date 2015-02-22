class String
  def is_number?
    begin 
      return true if Float(self)
    rescue
      return false
    end
  end
  
  def to_b
    return true if self =~ (/^(true|t|yes|y|1)$/i)
    return false if self.empty? || self =~ (/^(false|f|no|n|0)$/i)

    raise ArgumentError.new "invalid value: #{self}"
  end
end