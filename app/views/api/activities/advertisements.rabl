collection @advertisements

node :poster do |advertisement|
  "#{ ENV['KOALA_DOMAIN'] }#{ url_for advertisement.poster.representation(resize: 'x1080') }" if advertisement.poster.attached?
end
