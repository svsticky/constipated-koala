class Advertisement < ApplicationRecord
  validates :name, presence: true

  has_one_attached :poster
  validate :content_type

  private
  def content_type
    # TODO error message
    errors.add(:poster, 'Wrong content_type') unless poster.attached? && poster.content_type.in?(['application/pdf', 'image/jpeg', 'image/png'])
  end
end
