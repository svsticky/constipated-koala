class Education < ActiveRecord::Base
  #DO NOT change this order without clearing the entire table
  enum name_id: [ :ICA, :IKU, :GT, :WISK, :COSC, :GMTE, :MBIM, :AINM ]
  
  validates :name_id, presence: true
  validates :start_date, presence: true
  #validates :end_date
  
  belongs_to :member
  
  def name(study)
    if study.ICA?
      'Informatica'
    elsif study.IKU?
      'Informatiekunde'
    elsif study.GT?
      'Gametechnologie'
    elsif study.WISK?
      'Wiskunde'
    elsif study.COSC?
      'Computing science'
    elsif study.GMTE?
      'Game and media technology'
    elsif study.MBIM?
      'Business informatics'
    elsif study.AINM?
      'Artificial intelligence'
    else
      'unknown'
    end
  end
  
  def list
    [['--', ''],
    ['INFORMATICA', :ICA], 
    ['INFORMATIEKUNDE', :IKU], 
    ['GAMETECHNOLOGIE', :GT], 
    ['WISKUNDE', :WISK], 
    ['GAME AND MEDIA TECHNOLOGY', :GMTE], 
    ['BUSINESS INFORMATICS', :MBIM], 
    ['ARTIFICIAL INTELLIGENCE', :AINM]]
  end
  
end
