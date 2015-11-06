collection @participants

attributes :id, :paid
attribute :currency => :price

child :activity do
  attributes :id, :name, :start_date, :end_date
end
