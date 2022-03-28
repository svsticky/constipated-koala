#:nodoc:
class GroupMember < ApplicationRecord
  belongs_to :member
  belongs_to :group

  validates :year, presence: true

  is_impressionable

  def position=(position)
    write_attribute(:position, position)
    write_attribute(:position, nil) if position.blank? || position == '-'
  end

  delegate :name, to: :member
end
