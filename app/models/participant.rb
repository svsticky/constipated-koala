class Participant < ActiveRecord::Base
  validates :paid, presence: true

  belongs_to :member
  belongs_to :activity
end