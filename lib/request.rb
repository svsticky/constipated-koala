require 'json'
require 'ostruct'

require 'net/http'
require 'uri'

#:nodoc:
module ConstipatedKoala
  #:nodoc:
  class Request
    def initialize(domain)
      @uri = URI.parse domain

      @client = Net::HTTP.new(@uri.host, @uri.port)
      @client.set_debug_output($stdout) unless Rails.env.production?
      @client.use_ssl = true
      @client.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def get(path, query = {})
      path = path.chomp('/') + '?' + URI.encode_www_form(query) unless query.blank?

      request = Net::HTTP::Get.new(path.chomp('/'))
      request['Accept'] = 'application/json'

      return request
    end

    def post(path, body = {})
      request = Net::HTTP::Post.new(path.chomp('/'))

      body.delete_if { |_, v| v.nil? }
      request.body = URI.encode_www_form(body)

      request['Accept'] = 'application/json'
      return request
    end

    def delete(path)
      request = Net::HTTP::Delete.new(path.chomp('/'))

      request['Accept'] = 'application/json'
      return request
    end

    def send!(request)
      begin
        response = @client.request(request)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => error
        raise SocketError error.message
      end

      case response.code.to_i
      when 200, 201
        JSON.parse(response.read_body, object_class: OpenStruct)
      when 204
        {}
      else
        Rails.logger.debug @client.inspect
        raise ArgumentError, response.code.to_i
      end
    end
  end
end
