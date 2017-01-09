require 'json'
require 'net/http'
require 'uri'

class Client
  def self.request(request, body = {})
    return @client if defined? @client

    uri = URI.parse(ENV['MOLLIE_DOMAIN'])
    uri.query = URI.encode_www_form(body) unless body.blank?

    @client = Net::HTTP.new(uri.host, uri.port)
    @client.use_ssl = true
    @client.verify_mode = OpenSSL::SSL::VERIFY_PEER

    @client.request(request)
  end

  def self.parse!(response)
    Rails.logger.debug response.inspect

    case response.code.to_i
    when 200, 201
      self.nested_underscore_keys JSON.parse(response.body)
    when 204
      {}
    else
      raise ArgumentError.new(response.code.to_i)
      Rails.logger.fatal response['error']['field'] unless response['error']['field'].nil?
    end
  end

  def nested_underscore_keys(hash)
    hash.each_with_object({}) do |(key, value), underscored|
      if value.is_a?(Hash)
        underscored[underscore(key)] = nested_underscore_keys(value)
      elsif value.is_a?(Array)
        underscored[underscore(key)] = value.map { |v| nested_underscore_keys(v) }
      else
        underscored[underscore(key)] = value
      end
    end
  end

  def camelize_keys(hash)
    hash.each_with_object({}) do |(key, value), camelized|
      camelized[camelize(key)] = value
    end
  end

  def underscore(string)
    string.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr("-", "_").
      downcase.to_s
  end
end
