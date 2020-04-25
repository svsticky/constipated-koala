# A post is a message viewable by members if published. The author is polymorphic however
# for now only use from an admin user is possible
class Post < ApplicationRecord
  belongs_to :author, :polymorphic => true
  serialize :tags

  validates :status, presence: true
  validates :published_at, presence: true, if: -> { scheduled? }

  enum status: [:draft, :published, :review, :scheduled]

  default_scope { order('published_at IS NOT NULL, published_at DESC') }
  scope :pinned, -> { where(id: Settings['posts.pinned']) }
  scope :unpinned, -> { where.not(id: Settings['posts.pinned']) }

  attr_accessor :pinned

  def tags=(tags)
    write_attribute(:tags, tags.split(' '))
  end

  def pinned?
    Settings['posts.pinned'].include? id
  end

  before_save do
    if published? && published_at.nil?
      self.published_at = Time.now
    elsif !published? && !scheduled?
      self.published_at = nil
    end
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

# t.text "content"
# t.integer "status", default: 0, null: false
# t.string "tags"
# t.string "author_type", null: false
# t.bigint "author_id", null: false
# t.datetime "created_at", precision: 6, null: false
# t.datetime "updated_at", precision: 6, null: false
# t.datetime "published_at"
# t.index ["author_type", "author_id"], name: "index_posts_on_author_type_and_author_id"
