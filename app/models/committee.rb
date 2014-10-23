class Committee < ActiveRecord::Base
  validates :name, presence: true

  has_many :committeeMembers,
    :dependent => :destroy
  has_many :members, :through => :committeeMembers
end
