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

  after_validation(on: :create) do
    response = Net::HTTP.post_form(
      URI("#{ENV['IDEAL_PLATFORM']}/"),
      {
        'description' => self.description,
        'amount' => self.amount,
        'issuer' => self.issuer,
        'type' => self.type
      }
    )

    if response.code != '200'
      logger.fatal response.inspect
      raise ArgumentError
    end

    object = JSON.parse( response.body )

    self.uuid = object['uuid']
    self.url = object['url']
  end

  after_find do |transaction|
    response = Net::HTTP.get_response(URI("#{ENV['IDEAL_PLATFORM']}/?uuid=#{self.uuid}"))

    if response.code != '200'
      logger.fatal response.inspect
      raise ArgumentError
    end

    object = JSON.parse( response.body )

    self.description = object['description']
    self.amount = object['amount']
    self.issuer = object['issuer']
    self.status = object['status']
    self.type = object['type']
  end

  def self.list( limit, offset )
    response = Net::HTTP.get_response( URI("#{ENV['IDEAL_PLATFORM']}/?limit=#{limit}&offset=#{offset}") )

    if response.code != '200'
      logger.fatal response.inspect
      raise ArgumentError
    end

    objects = JSON.parse( response.body )
    return IdealTransaction.merge( objects )
  end

  private
  def self.merge( objects )

    objects.each do |object|

      transaction = IdealTransaction.find_by_uuid( object['uuid'] )

      # NOTE no koala transaction, continue
      next if transaction.nil?

      object.merge!( transaction.attributes )
      object.merge!( 'member' => transaction.member ) if transaction.member.present?

      if object['transaction_type'] == 'Activity'
        activities = Activity.where( :id => object['transaction_id'] ).select( :id, :name, :price )
        object.merge!( 'activities' => activities.to_a ) unless activities.nil?

      elsif object['transaction_type'] == 'CheckoutTransaction'
        products = CheckoutTransaction.where( :id => object['transaction_id'] )
        object.merge!( 'checkout' => products ) unless products.nil?

      end

      object.compact
    end

    return objects
  end
end
