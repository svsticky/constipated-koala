class IdealTransaction < ActiveRecord::Base
  require 'net/http'
  require 'uri'
 
  attr_accessor :description, :amount, :issuer, :type, :url, :status
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
    response = Net::HTTP.post_form( 
      URI('http://ideal.local'), 
      {
        'description' => self.description, 
        'amount' => self.amount, 
        'issuer' => self.issuer, 
        'type' => self.type 
      }
    )

    if response.code != '200'
      raise ArgumentError
      return
    end

    object = JSON.parse( response.body )
    
    self.uuid = object['uuid']
    self.url = object['url']
  end
  
  after_find do |transaction|
    response = Net::HTTP.get_response(URI("http://ideal.local?uuid=#{self.uuid}"))

    if response.code != '200'
      raise ArgumentError
      return false
    end
    
    object = JSON.parse( response.body )

    self.description = object['description']
    self.amount = object['amount']
    self.issuer = object['issuer']    
    self.status = object['status']
    self.type = object['type']
  end
end
