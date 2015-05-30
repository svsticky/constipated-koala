class UserConfiguration < ActiveRecord::Base
  validates :abbreviation, presence: true
  
  validates :name, presence: true
#  validates :description
  
  validates :value, presence: true

  validates :config_type, presence: true
  enum config_type: { boolean: 1, array: 2 }
  
#  validates :options

  def method_missing( method, *args, &block )
    instance = UserConfiguration.find_by_abbreviation( method.to_s )
    
    unless instance.nil?
      if instance.config_type == 'array' 
        return instance.value.to_a
      elsif instance.config_type == 'boolean'
        return instance.value.to_b
      end
      
      return instance.value
    end
    
    super
  end  
end