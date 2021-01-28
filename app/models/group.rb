#:nodoc:
class Group < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true

  enum category: { board: 1, committee: 2, moot: 3, other: 4 }

  has_many :activities, :foreign_key => :organized_by

  has_many :group_members,
           :dependent => :destroy
  has_many :members,
           :through => :group_members

  is_impressionable

  def years
    # TODO: remove years without members
    years_in_existence = if created_at.nil?
                           [Date.today.year]
                         else
                           (created_at.study_year..Date.today.study_year)
                         end
    years_in_existence.map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse
  end

  def positions
    return ['chairman', 'secretary', 'treasurer', 'internal', 'external', 'education'] if board?

    return (['chairman', 'treasurer', 'board'] + Settings['additional_positions.committee'] + group_members.select(:position).order(:position).uniq.map(&:position)).compact.uniq if committee?

    return (['chairman', 'secretary', 'treasurer'] + Settings['additional_positions.moot'] + group_members.select(:position).order(:position).uniq.map(&:position)).compact.uniq if moot?

    return ['chairman', 'treasurer']
  end

  def members(year = nil)
    year = year.nil? ? Date.today.study_year : year.to_i

    # Sort on position, then name, then fallback to natural occurring order
    group_members.where(:year => year).sort do |a, b|
      if a.position.present? && b.position.present?
        if a.position == b.position
          if a.member.nil?
            1
          elsif b.member.nil?
            -1
          else
            a.name <=> b.name
          end
        else
          positions.index(a.position) <=> positions.index(b.position)
        end
      elsif a.position.nil? && b.position.nil?
        if a.member.nil?
          1
        elsif b.member.nil?
          -1
        else
          a.name <=> b.name
        end
      elsif a.position.nil?
        1
      elsif b.position.nil?
        -1
      elsif a.member.nil?
        1
      elsif b.member.nil?
        -1
      end
    end
  end

  def self.has_members # rubocop:disable Naming/PredicateName
    # joins(:group_members).select('`groups`.*, COUNT( `groups`.`id` ) as members').group('`groups`.`id`').having('members > 0')
    Group.where(id: GroupMember.all.select(:group_id).distinct)
  end
end
