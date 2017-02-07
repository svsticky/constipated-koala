object @activity
attributes :id, :name, :description, :price, :location

node :start_date do |activity|
  if activity.start_time.nil?
    activity.start_date
  else
    d = activity.start_date
    t = activity.start_time
    Time.new(d.year, d.month, d.day, t.hour, t.min, 0).iso8601
  end
end

node :end_date do |activity|
  if activity.end_time.nil?
    activity.end_date
  else
    d = activity.end_date
    t = activity.end_time
    Time.new(d.year, d.month, d.day, t.hour, t.min, 0).iso8601
  end
end

node :unenroll_date do |activity|
  if activity.unenroll_date
  	activity.unenroll_date.iso8601
  end
end

node :attendees do |activity|
  attendees = []
  @activity.attendees.joins(:member).order('members.first_name', 'members.last_name').each do |participant|
    attendees << participant.member.name
  end
  attendees
end

node :reservists do |activity|
  reservists = []
  @activity.reservists.joins(:member).order('members.first_name', 'members.last_name').each do |participant|
    reservists << participant.member.name
  end
  reservists
end

glue :group do
  attribute :name => :group
end

node :poster do |activity|
  activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end

node :enrollable do |activity|
  !activity.participant_limit.nil? && activity.attendees.count < activity.participant_limit
end

node :location do |activity|
  activity.location unless activity.location.nil?
end
