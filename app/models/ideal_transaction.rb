class IdealTransaction < ActiveRecord::Base
  require 'net/http'
  require 'uri'

  attr_accessor :description, :amount, :issuer, :type, :url, :status
  validates :description, presence: true
  validates :amount, presence: true
  validates :issuer, presence: true
  validates :type, presence: true

  belongs_to :member
  validates :member, presence: true

  validates :transaction_type, presence: true
  serialize :transaction_id, Array

  after_validation(on: :create) do
    response = IdealTransaction::post('payments', NIL, {
      :amount => self.amount,
      :description => self.description,
      :issuer => self.issuer,

      :metadata => {
        :id => self.id,
        :member => member.name,
        :activity => activity.name
      }
    })

    self.uuid = response.id
  end

  after_find do |transaction|
    response = IdealTransaction::get('payments', self.uuid)

    self.description = response.description
    self.amount = response.amount
    self.status = response.status

    #self.issuer = object['issuer'] TODO remove
    #self.type = object['type'] TODO remove
  end

  def self.list( count, offset )
    response = IdealTransaction::get('payments', NIL, { :count => count, :offset => offset })
    logger.debug response

    response
  end

  private
  def self.get( method, id = NIL, body = {} )
    request = Net::HTTP::Get.new("/#{ENV['MOLLIE_VERSION']}/#{method}/#{id}".chomp('/'))

    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['MOLLIE_TOKEN']}"

    begin
      response = Client.request(request, body)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      raise SocketError error.message
    end

    Client.parse! response
  end


  def self.post( method, id = NIL, body = {} )
    request = Net::HTTP::Post.new("/#{ENV['MOLLIE_VERSION']}/#{method}/#{id}".chomp('/'))

    body.delete_if { |k, v| v.nil? }
    request.body = body

    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['MOLLIE_TOKEN']}"

    begin
      response = Client.request(request)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      raise SocketError error.message
    end

    Client.parse! response
  end

  def self.delete( method, id = NIL )
    request = Net::HTTP::Delete.new("/#{ENV['MOLLIE_VERSION']}/#{method}/#{id}".chomp('/'))

    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['MOLLIE_TOKEN']}"

    begin
      response = Client.request(request)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
      raise SocketError error.message
    end

    Client.parse! response
  end
end
