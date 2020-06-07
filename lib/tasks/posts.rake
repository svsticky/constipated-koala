namespace :posts do
  desc 'Publish a post whenever it\'s scheduled to release'
  task :publish => :environment do
    Post.where(status: :scheduled).where('published_at <= ?', Time.current).update_all(status: :published)
  end
end
