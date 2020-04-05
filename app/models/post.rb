class Post < ApplicationRecord
  belongs_to :author, :polymorphic => true
  serialize :tags

  validates :status, presence: true
  validates :published_at, presence: true, if: -> { self.scheduled? }

  enum status: [:draft, :published, :review, :scheduled]

  default_scope { order('published_at IS NOT NULL, published_at DESC') }
  scope :pinned, -> { where(id: Settings['posts.pinned']) }
  scope :unpinned, -> { where.not(id: Settings['posts.pinned']) }

  attr_accessor :pinned

  def tags=(tags)
    write_attribute(:tags, tags.split(' '))
  end

  def pinned?
    Settings['posts.pinned'].include? self.id
  end

  before_save do
    if self.published? && self.published_at.nil?
      self.published_at = Time.now
    elsif !self.published? && !self.scheduled?
      self.published_at = nil
    end
  end

  after_save do
    if Settings['posts.pinned'].include?(id) && self.pinned != '1'
      Settings['posts.pinned'] = Settings['posts.pinned'].reject{ |i| id == i }
    elsif self.pinned == '1'
      Settings['posts.pinned'] = Settings['posts.pinned'] << id
    end
  end

  after_destroy do
    Settings['posts.pinned'] = Settings['posts.pinned'].reject{ |i| id == i }
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
