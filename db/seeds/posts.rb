require Rails.root.join('db', 'seeds', 'users.rb')

puts '-- Creating posts'

6.times do
  created_at = Faker::Time.between(from: 2.years.ago, to: Date.yesterday)

  Post.create(
    status: [0,1].sample,
    tags: 'test test2',

    author: Admin.all.sample,

    created_at: created_at,
    published_at: Faker::Time.between(from: created_at, to: Date.today),

    content: <<~EOT
      <h5>Maandag 13:30: Boulderen / Bouldering</h5>
      WEL klimmen, GEEN zekering nodig. Kom vrij klimmen in Boulderhal Energiehaven met de sportcommissie!
      <a href="https://koala.svsticky.nl/activities/909">https://koala.svsticky.nl/activities/909</a>

      <h5>Dinsdag 13:00: Ode to your CODE (hulpmiddag)</h5>
      Op 21 januari, een week voor het grote CODE practicum, organiseert Sticky een hulpmiddag in BBG 1.79 van 13:00u tot 17:00u. Hier kan je extra vragen stellen en de laatste hand leggen aan je practicum. Wij zorgen voor koffie, thee en koekjes.
      <a href="https://koala.svsticky.nl/activities/904">https://koala.svsticky.nl/activities/904</a>
    EOT
  )

end

# Set first post to pinned
Settings['posts.pinned'] = [Post.published&.first&.id]

