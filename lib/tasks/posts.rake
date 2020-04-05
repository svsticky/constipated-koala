# Sends a mail to members every year (except second and fourth year) requesting updating their study information. If no active studies are filled in consent is requested.
# create a cronjob executing this ones a year; bundle exec rake status:mail
namespace :posts do
  desc 'Mail members for updating their status'
  task :publish => :environment do
    Post.where(status: :scheduled).where('published_at <= ?', Time.current).update_all(status: :published)
  end
end
