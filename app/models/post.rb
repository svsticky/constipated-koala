# A post is a message viewable by members if published. The author is polymorphic however
# for now only use from an admin user is possible
class Post < ApplicationRecord
  include Sidekiq::Worker

  belongs_to :author, polymorphic: true
  serialize :tags

  validates :status, presence: true
  validates :published_at, presence: true
  validates :title, length: { maximum: 100 }

  enum status: { draft: 0, published: 1 }

  default_scope { where.not(published_at: nil).order(published_at: :desc) }
  scope :pinned, -> { where(pinned: 1) }
  scope :unpinned, -> { where(pinned: 0) }

  def tags=(tags)
    write_attribute(:tags, tags.split)
  end

  before_validation(on: :create) do
    self.published_at = Time.current if published_at.nil?
  end

  before_save do
    Post.where.not(id: id).find_each { |post| post.update(pinned: false) } if pinned == true
  end
end
