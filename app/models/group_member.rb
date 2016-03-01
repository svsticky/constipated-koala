class GroupMember < ActiveRecord::Base
  belongs_to :member
  belongs_to :group

  validates :year, presence: true
#  validates :position

  is_impressionable

  def position=(position)
    write_attribute( :position, position )
    write_attribute( :position, NIL ) if position.blank? || position == '-'
  end

  def name
    member.name
  end
end
