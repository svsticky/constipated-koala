class Tag < ActiveRecord::Base
  #DO NOT change this order without clearing the entire table
  enum name_id: [ :DECEASED, :PARDON ]
  
  validates :name_id, presence: true
  belongs_to :member
  
  def name(tag)
    if tag.DECEASED?
      'overleden'
    elsif tag.PARDON?
      'gratie'
    else
      'unknown'
    end
  end
  
  #DO NOT change this order
  def self.list
    [['overleden', :DECEASED], 
    ['gratie', :PARDON]]
  end
end