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
      URI(ENV['IDEAL_PLATFORM']), 
      {
        'description' => self.description, 
        'amount' => self.amount, 
        'issuer' => self.issuer, 
        'type' => self.type 
      }
    )

    if response.code != '200'
      logger.error response.inspect
      raise ArgumentError
    end

    object = JSON.parse( response.body )
    
    self.uuid = object['uuid']
    self.url = object['url']
  end
  
  after_find do |transaction|
    response = Net::HTTP.get_response(URI("#{ENV['IDEAL_PLATFORM']}?uuid=#{self.uuid}"))

    if response.code != '200'
      logger.debug response.code
      raise ArgumentError
    end
    
    object = JSON.parse( response.body )

    self.description = object['description']
    self.amount = object['amount']
    self.issuer = object['issuer']    
    self.status = object['status']
    self.type = object['type']
  end
  
  def self.find_by_date( date )
    response = Net::HTTP.get_response( URI("#{ENV['IDEAL_PLATFORM']}?date=#{date}") )

    if response.code != '200'
      logger.debug response.code
      raise ArgumentError
    end
  
    objects = JSON.parse( response.body )
    objects.each do |object| 
      object.merge!( IdealTransaction.where( :uuid => object['uuid'] ).first.attributes.slice!( 'created_at', 'updated_at' ) ) unless IdealTransaction.where( :uuid => object['uuid'] ).empty? 
      object.merge!( 'member' => Member.find_by_id( object['member_id'] ) ).delete( 'member_id') unless object['member_id'].nil?
      object.merge!( 'activities' => Activity.where( :id => object['transaction_id'] ).to_a ).delete( 'transaction_id' ).delete( 'transaction_type' ) unless object['transaction_id'].nil? || object['transaction_type'] != 'Activity'
      object.compact
    end
    
    return objects
  end
  
  def self.summary( objects )
    summary = Hash.new
    
    objects.each do |object|
      
      next unless object['status'] == 'SUCCESS'
      
      if !object['activities'].nil?
        object['activities'].each do |activity|
          summary.merge!( activity => summary[activity] + activity.participants.where( :member => object['member'] ).first.currency ) if summary.has_key?( activity )
          summary.merge!( activity => activity.participants.where( :member => object['member'] ).first.currency ) unless summary.has_key?( activity )
        end
      else
        summary.merge!( object['type'] => summary[ object['type'] ] + object['amount'] ) if summary.has_key?( object['type'] )
        summary.merge!( object['type'] => object['amount'] ) unless summary.has_key?( object['type'] )
      end
    
    end
    
    logger.debug summary.inspect
    
    return summary
  end
end
