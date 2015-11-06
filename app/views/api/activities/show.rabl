object @activity
attributes :id, :name, :description, :start_date, :end_date, :price

glue :group do
  attribute :name => :group
end

node :poster do
  |activity| activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end

child :participants do |participant|
  attributes :id, :created_at, :if => lambda { |participant| participant.member == Authorization._member }

  glue :member do
    attribute :name
  end

  # TODO is there a better way instead of using the same if twice
  attribute :currency => :price, :if => lambda { |participant| participant.member == Authorization._member }
  attribute :paid, :if => lambda { |participant| participant.member == Authorization._member }
end
