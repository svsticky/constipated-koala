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

    raise ArgumentError.new "invalid value: #{ self }"
  end
end

class Date
  # Return the first year of a study year, hence 2014 means the year 2014-2015
  def study_year
    if self.month < 8
      return self.year.to_i - 1
    else
      return self.year
    end
  end

  def self.to_date(year)
    return Date.new(year, 8, 1)
  end

  # Make s list of consecutive years without interuptions
  def self.years(list)
    current = last = 0
    years = Array.new

    list.each do |year|
      last = Date.find_consecutive_year(list, year)

      if current != last
        years.push("#{ year } - #{ 1 + last }")
        current = last
      end
    end

    return years.join('. ')
  end

  private

  def self.find_consecutive_year(years, year)
    # return same year if no succesive year
    return year unless years.include? 1 + year

    # take next year and try further
    return Date.find_consecutive_year(years, 1 + year)
  end
end

class Time
  def before(time)
    return Time.zone.parse(time).to_i > self.to_i
  end

  # Return the first year of a study year using time, hence 2014 means the year 2014-2015
  def study_year
    if self.month < 8
      return self.year.to_i - 1
    else
      return self.year
    end
  end
end

class Hash
  def compact
    delete_if { |k, v| v.nil? }
  end
end

class Array
  def only(*keys)
    map do |hash|
      hash.select do |key, value|
        keys.map { |symbol| symbol.to_s }.include? key.to_s
      end
    end
  end
end
