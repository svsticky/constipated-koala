# A post is a message viewable by members if published. The author is polymorphic however
# for now only use from an admin user is possible
class Post < ApplicationRecord
  include Sidekiq::Worker

  belongs_to :author, :polymorphic => true
  serialize :tags

  validates :status, presence: true
  validates :published_at, presence: true
  validates :title, length: { maximum: 100 }

  enum status: [:draft, :published, :review]

  default_scope { where.not(published_at: nil).order(published_at: :desc) }
  scope :pinned, -> { where(id: Settings['posts.pinned']) }
  scope :unpinned, -> { where.not(id: Settings['posts.pinned']) }

  attr_accessor :pinned

  def tags=(tags)
    write_attribute(:tags, tags.split(' '))
  end

  def pinned?
    Settings['posts.pinned'].include? id
  end

  before_validation(on: :create) do
    self.published_at = Time.now if published_at.nil?
  end

  after_save do
    if Settings['posts.pinned'].include?(id) && pinned != '1'
      Settings['posts.pinned'] = Settings['posts.pinned'].reject { |i| id == i }
    elsif pinned == '1'
      Settings['posts.pinned'] = Settings['posts.pinned'] << id
    end
  end

  after_destroy do
    Settings['posts.pinned'] = Settings['posts.pinned'].reject { |i| id == i }
  end
end
