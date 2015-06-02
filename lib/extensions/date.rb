class Date
  def self.start_studyyear( year )
    if Date.today.month < 9
      return Date.new( year -1, 9, 1)
    else
      return Date.new( year, 9, 1 )
    end
  end
end
