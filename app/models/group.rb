class Group < ActiveRecord::Base
  validates :name, presence: true
  validates :category, presence: true

#  validates :comments

  enum category: { board: 1, committee: 3, other: 4 }

  has_many :group_members,
    :dependent => :destroy
  has_many :members,
    :through => :group_members
end
