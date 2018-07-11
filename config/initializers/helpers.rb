#:nodoc:
class String
  def is_number? # rubocop:disable PredicateName
    return true if Float(self)
  rescue StandardError
    return false
  end

  def to_b
    return true if self =~ /^(true|t|yes|y|1)$/i
    return false if empty? || self =~ /^(false|f|no|n|0)$/i

    raise ArgumentError, "invalid value: #{ self }"
  end
end

#:nodoc:
class Integer
  def to_study_year
    "#{ self } - #{ self + 1 }"
  end
end

#:nodoc:
class Date
  # Return the first year of a study year, hence 2014 means the year 2014-2015
  def study_year
    return (year.to_i - 1) if month < 8
    return year
  end

  def self.to_date(year)
    return Date.new(year, 8, 1)
  end

  # Make s list of consecutive years without interuptions
  def self.years(list)
    current = last = 0
    years = []

    list.each do |year|
      last = Date.find_consecutive_year(list, year)

      if current != last
        years.push("#{ year } - #{ 1 + last }")
        current = last
      end
    end

    return years.join('. ')
  end

  def self.find_consecutive_year(years, year)
    # return same year if no succesive year
    return year unless years.include? 1 + year

    # take next year and try further
    return Date.find_consecutive_year(years, 1 + year)
  end
end

#:nodoc:
class Time
  def before(time)
    return Time.zone.parse(time).to_i > to_i
  end

  # Return the first year of a study year using time, hence 2014 means the year 2014-2015
  def study_year
    return (year.to_i - 1) if month < 8
    return year
  end
end

#:nodoc:
class Hash
  def compact
    delete_if { |_, v| v.nil? }
  end
end

#:nodoc:
class Array
  def only(*keys)
    map do |hash|
      hash.select do |key, _|
        keys.map(&:to_s).include? key.to_s
      end
    end
  end
end
