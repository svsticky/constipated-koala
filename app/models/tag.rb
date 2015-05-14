class Tag < ActiveRecord::Base
  #DO NOT change this order without clearing the entire table
  enum name_id: [ :DECEASED, :PARDON, :MERIT, :HONORARY ]
  
  validates :name_id, presence: true
  belongs_to :member
  
  def name(tag)
    if tag.DECEASED?
      'overleden'
    elsif tag.PARDON?
      'gratie'
    elsif tag.MERIT?
      'lid van verdienste'
    elsif tag.HONORARY?
      'erelid'
    else
      'unknown'
    end
  end
  
  #DO NOT change this order
  def self.list
    [['overleden', :DECEASED], 
    ['gratie', :PARDON],
    ['lid van verdienste', :MERIT],
    ['erelid', :HONORARY]]
  end
  
  def self.active_by_tag
    [ 1, 2, 3 ]
  end
end
