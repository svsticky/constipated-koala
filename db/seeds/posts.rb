require Rails.root.join('db', 'seeds', 'users.rb')

puts '-- Creating posts'

6.times do
  created_at = Faker::Time.between(from: 2.years.ago, to: Date.yesterday)

  post = Post.create(
    title: Faker::Movie.title,
    status: [0, 1].sample,
    tags: Faker::Lorem.sentence(word_count: 2),

    author: Admin.all.sample,

    created_at: created_at,
    published_at: Faker::Time.between(from: created_at, to: Date.today),

    content: Faker::Lorem.paragraph(sentence_count: 5)
  )

  puts "   [#{ post.valid? ? ' Ok ' : 'Fail' }] #{ post.title } by #{ post.author.first_name } #{ post.author.last_name }"
  post.errors.objects.each do |error|
    puts "          > #{error.full_message}"
  end
end
