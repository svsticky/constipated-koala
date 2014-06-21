class Education < ActiveRecord::Base
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
    ['Informatica', :ICA], 
    ['Informatiekunde', :IKU], 
    ['Gametechnologie', :GT], 
    ['Wiskunde', :WISK], 
    ['Game and media technology', :GMTE], 
    ['Business informatics', :MBIM], 
    ['Artificial intelligence', :AINM]]
  end
  
end
