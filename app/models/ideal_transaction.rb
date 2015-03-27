class IdealTransaction < ActiveRecord::Base
  require 'net/http'
  require 'uri'
 
  attr_accessor :description, :amount, :issuer, :type, :url
  validates :description, presence: true
  validates :amount, presence: true
  validates :issuer, presence: true
  validates :type, presence: true
  
  #validates :uuid
  #validates :status
  
  belongs_to :member
  validates :member, presence: true
  
  validates :transaction_type, presence: true
  serialize :transaction_id, Array
  
  after_validation do
    response = Net::HTTP.post_form( 
      URI('http://kebetalingen.isaanhetwerk.nl'), 
      {
        'description' => self.description, 
        'amount' => self.amount, 
        'issuer' => self.issuer, 
        'type' => self.type 
      }
    )

    if response.code != '200'
      return false
    end

    object = JSON.parse( response.body )
    
    self.uuid = object['uuid']
    self.url = object['url']
  end
end
