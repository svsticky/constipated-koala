object @activity
attributes :id, :name, :description, :price

node :start_date do |activity|
  activity.start_date.strftime('%Y-%m-%d')
end

node :start_time do |activity|
  activity.start_date.strftime('%H:%M')
end

node :end_date do |activity|
  activity.end_date.strftime('%Y-%m-%d') unless activity.end_date.nil?
end

node :end_time do |activity|
  activity.end_date.strftime('%H:%M') unless activity.end_date.nil?
end

glue :group do
  attribute :name => :group
end

node :poster do |activity|
  activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end
