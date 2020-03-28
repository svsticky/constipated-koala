class Post < ApplicationRecord
  belongs_to :author, :polymorphic => true

  validates :status, presence: true
  enum status: [:draft, :published]

  default_scope { order(published_at: :desc) }
  scope :pinned, -> { where(status: :published) } #TODO add pinned setting

  def tags
    read_attribute(:tags).split(',')
  end

  def tags=(tags)
    write_attribute(:tags, tags.join(','))
  end

  before_update do
    # if paid, fix price in participant
    if status_changed? && self.published? && self.published_at.nil?
      self.published_at = Time.now
    end
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
