class IdealTransaction < ActiveRecord::Base
  require 'net/http'
  require 'uri'
 
  attr_accessor :description, :amount, :issuer, :type, :url
  validates :description, presence: true
  validates :amount, presence: true
  validates :issuer, presence: true
  validates :type, presence: true
  
  #validates :uuid
  
  belongs_to :member
  validates :member, presence: true
  
  validates :transaction_type, presence: true
  serialize :transaction_id, Array
  
  after_validation do
    json = Net::HTTP.post_form( 
      URI('betalingen.isaanhetwerk.nl'), 
      {
        'description' => "Introductie #{@member.first_name} #{@member.infix} #{@member.last_name}", 
        'amount' => @total, 
        'issuer' => params[:bank], 
        'type' => 'INTRO' 
      }
    )
    
    response = JSON.parse( json )
    
    self.uuid = response['uuid']
    self.url = response['url']
    
    # TODO if something is wrong rollback
  end
end
