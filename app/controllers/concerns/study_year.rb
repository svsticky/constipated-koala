# Module to create a range from a single year, study years are stored as the year they start in
module StudyYear
  include ActiveSupport::Concern

  def range(beginning)
    if beginning >= Date.today.study_year
      return [Date.today.study_year].map do |year|
        ["#{ year }-#{ year + 1 }", year]
      end
    end

    return (Activity.first.start_date.year..Date.today.study_year).map do |year|
      ["#{ year }-#{ year + 1 }", year]
    end
  end
end
