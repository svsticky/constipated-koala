class Committee < ActiveRecord::Base
    validates :name, presence: true

    has_many :committee_members,
        :dependent => :destroy
    has_many :members, :through => :participants
end
