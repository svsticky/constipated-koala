class Date
  def self.study_year( year )
    if Date.today.month < 8
      return Date.new( year -1, 8, 1)
    else
      return Date.new( year, 8, 1 )
    end
  end

  def study_year
    if self.month < 8
      return self.year.to_i-1
    else
      return self.year
    end
  end
end

class Time
  def study_year
    if self.month < 8
      return self.year.to_i-1
    else
      return self.year
    end
  end
end
