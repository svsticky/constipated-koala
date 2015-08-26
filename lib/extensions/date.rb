class Date

  # Return the first year of a study year, hence 2014 means the year 2014-2015
  def study_year
    if self.month < 8
      return self.year.to_i-1
    else
      return self.year
    end
  end

  # Create a comparer date for a specific year
  def self.study_year( year )
    if Date.today.month < 8
      return Date.new( year -1, 8, 1)
    else
      return Date.new( year, 8, 1 )
    end
  end

  # Make s list of consecutive years without interuptions
  def self.years( list )
    current = last = 0
    years = Array.new

    list.each do |year|
      last = Date.find_consecutive_year( list, year )

      if current != last
        years.push(  "#{year} - #{1+ last}" )
        current = last
      end
    end

    return years.join('. ')
  end

  private
  def self.find_consecutive_year( years, year )
    # return same year if no succesive year
    return year unless years.include? 1+ year

    # take next year and try further
    return Date.find_consecutive_year( years, 1+ year)
  end
end

class Time

  # Return the first year of a study year using time, hence 2014 means the year 2014-2015
  def study_year
    if self.month < 8
      return self.year.to_i-1
    else
      return self.year
    end
  end
end
