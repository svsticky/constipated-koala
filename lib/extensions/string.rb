class String
  def is_number?
    begin 
      return true if Float(self)
    rescue
      return false
    end
  end
end