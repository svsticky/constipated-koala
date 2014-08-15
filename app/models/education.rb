class Education < ActiveRecord::Base
  belongs_to :study  
  belongs_to :member

  validates :start_date, presence: true
  #validates :end_date
 /   
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
  /
end
