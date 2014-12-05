class Study < ActiveRecord::Base
  validates :name, presence: true
  validates :code, presence: true
#  validates :masters, presence: true, default: false
end