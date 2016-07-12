class Tag < ActiveRecord::Base
  enum name: { pardon: 1, merit: 2, honorary: 3, donator: 4 }

  validates :name, presence: true
  belongs_to :member
  
  def self.active_by_tag
    [ 1, 2, 3, 4 ]
  end
end
