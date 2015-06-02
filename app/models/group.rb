class Group < ActiveRecord::Base
  validates :name, presence: true
  validates :type, presence: true
  
  enum { board: 1, committee: 2, other: 4 }

  has_many :group_members,
    :dependent => :destroy
  has_many :members, 
    :through => :group_members
end
