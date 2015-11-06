collection @adverts
attribute :name

node :poster do
  |advert| advert.poster.url(:medium) unless advert.poster_updated_at.nil?
end
