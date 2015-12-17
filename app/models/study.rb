class Study < ActiveRecord::Base
  validates :code, presence: true
#  validates :masters, presence: true, default: false
end
