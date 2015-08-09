class Date
  def self.start_studyyear( year )
    if Date.today.month < 8
      return Date.new( year -1, 8, 1)
    else
      return Date.new( year, 8, 1 )
    end
  end
end
