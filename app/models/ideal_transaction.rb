class IdealTransaction < ActiveRecord::Base
  before_validation { self.uuid = SecureRandom.uuid }
  self.primary_key = :uuid
    
  validates :description, presence: true
  validates :price, presence: true
  
  belongs_to :member
  validates :member, presence: true
  serialize :activities, Array
  
  validates :issuer, presence: true
  validates :status, presence: true
end
