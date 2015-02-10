class Date
  def self.start_studyyear
    if Date.today.month < 9
      return Date.new(Date.today.year() -1, 9, 1)
    else
      return Date.new(Date.today.year, 9, 1)
    end
  end
end