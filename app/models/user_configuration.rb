class UserConfiguration < ActiveRecord::Base
  self.primary_key = 'abbreviation'
  validates :abbreviation, presence: true

  validates :name, presence: true
  validates :value, presence: true

  def value=(value)
    write_attribute( :value, value.split(',').to_s )
  end

  def value
    read_attribute( :value ).to_a.join(',')
  end

  # Doesn't do anything server needs to be reloaded or upgraded
  after_update do
    ENV["#{self.abbreviation}"] = "#{self.value}"
  end
end
