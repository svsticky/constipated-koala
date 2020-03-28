module StudyYear
  include ActiveSupport::Concern

  def range(beginning)

    if beginning >= Date.today.study_year
      return [Date.today.study_year].map {
        |year| ["#{year}-#{year+1}", year]
      }
    end

    return (Activity.first.start_date.year..Date.today.study_year).map {
      |year| ["#{ year }-#{ year + 1 }", year]
    }
  end

end
