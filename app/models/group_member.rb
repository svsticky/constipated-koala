#:nodoc:
class GroupMember < ApplicationRecord
  belongs_to :member
  belongs_to :group

  validates :year, presence: true

  before_destroy :rewrite_logs_before_delete!, prepend: true
  is_impressionable dependent: :nullify

  def position=(position)
    write_attribute(:position, position)
    write_attribute(:position, nil) if position.blank? || position == '-'
  end

  def name
    member.name
  end

  def rewrite_logs_before_delete!
    impressions.each do |impression|
      impression.update(message: log_action(impression.action_name))
    end
  end

  def log_action(action)
    I18n.t(
      action,
      scope: [:activerecord, :attributes, :impression, :group_member],
      member_type: (
        I18n.t group.category, scope: [:activerecord, :attributes, :group, :members]
      ).to_s.downcase,
      position: (
        I18n.t position, scope: [:activerecord, :attributes, :group, :positions], default: position.to_s
      ).to_s.downcase
    )
  end
end
