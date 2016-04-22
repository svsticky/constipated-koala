collection @advertisements

node :poster do |advertisement|
  advertisement.poster.url unless advertisement.poster_updated_at.nil?
end
