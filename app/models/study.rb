#:nodoc:
class Study < ApplicationRecord
  validates :code, presence: true
end
