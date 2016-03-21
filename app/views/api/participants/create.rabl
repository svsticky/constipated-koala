object @participant

attributes :paid, :created_at
attribute :currency => :price

child :activity do
  attributes :id, :name, :start_date, :end_date
end

if @transaction
  object @transaction

  attributes :url
end
