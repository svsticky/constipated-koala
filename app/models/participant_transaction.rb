class ParticipantTransaction < ApplicationRecord
  validates :member, presence: true
  belongs_to :member
  serialize :activity_id, Array

  def activities
    Activity.where(id: activity_id)
  end

  def participants
    Participant.where(member_id: member.id, activity_id: activity_id)
  end

  def sum
    participants.sum(&:currency)
  end
end
