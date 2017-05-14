class Study < ApplicationRecord
  validates :code, presence: true
#  validates :masters, presence: true, default: false
end
