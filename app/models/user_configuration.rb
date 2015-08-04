class UserConfiguration < ActiveRecord::Base
  validates :abbreviation, presence: true
  
  validates :name, presence: true
#  validates :description
  
  validates :value, presence: true

  validates :config_type, presence: true
  enum config_type: { boolean: 1, array: 2, integer: 3 }
  
  after_update do
    ENV["#{self.abbreviation}"] = "#{self.value}"
  end
end