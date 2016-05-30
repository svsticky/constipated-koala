object @activity
attributes :id, :name, :description, :start_date, :end_date, :price

node :start_time do |activity|
  activity.start_time.strftime('%H:%M') unless activity.start_time.nil?
end

node :end_time do |activity|
  activity.end_time.strftime('%H:%M') unless activity.end_time.nil?
end

glue :group do
  attribute :name => :group
end

node :poster do |activity|
  activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end
