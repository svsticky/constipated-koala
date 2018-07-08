#:nodoc:
class GroupMember < ApplicationRecord
  belongs_to :member
  belongs_to :group

  is_impressionable

  def position=(position)
    write_attribute(:position, position)
    write_attribute(:position, nil) if position.blank? || position == '-'
  end

  def name
    member.name
  end
end
