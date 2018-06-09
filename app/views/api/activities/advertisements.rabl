collection @advertisements

node :poster do |advertisement|
  "#{ ENV['KOALA_DOMAIN'] }#{ url_for advertisement.url }" if advertisement.poster.attached?
end
