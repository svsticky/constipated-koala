class Advertisement < ActiveRecord::Base
  validates :name, presence: true
  validates :visible, presence: true

  has_attached_file :poster, 
	:styles => { :thumb => ['180', :png], :medium => ['x720', :png] }, 
	:processors => [ :ghostscript, :thumbnail ], 
	:validate_media_type => false,
	:convert_options => { :all => '-colorspace CMYK -quality 100 -density 8' }

  validates_attachment_content_type :poster, 
	:content_type => ['application/pdf', 'image/jpeg', 'image/png']
 
 
  def self.list 
    list = Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today ).select(:id, :name, :start_date, :end_date, :poster_updated_at)\
            .map{ |item| (item.attributes.merge({ :poster => Activity.find(item.id).poster.url(:medium) }) if !item.poster_updated_at.nil?)}
    
    adverts = Advertisement.where( :visible => true ).select(:id, :poster_updated_at)\
            .map{ |item| (item.attributes.merge({ :poster => Advertisement.find(item.id).poster.url(:medium) }) if !item.poster_updated_at.nil?)}
    
    adverts.each_with_index{ |advert, i| list.insert( i * (list.length / adverts.length).ceil , advert ) }  # +i
    return list.compact.to_json
  end
end