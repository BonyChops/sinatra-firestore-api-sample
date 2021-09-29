require 'uri'
require 'net/http'
require 'cgi'
require 'addressable/uri'
require 'json'

class NetHttp
  def self.get(uri_string, data_object, headers = {})
    uri = URI.parse(uri_string + '?' + objectToString(data_object))
    req = Net::HTTP::Get.new(uri, headers)
    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) { |http| http.request(req) }
  end

  def self.post(uri_string, post_data_object, headers = {}, jsonMode = false)
    uri = URI.parse(uri_string)
    req = Net::HTTP::Post.new(uri, headers)
    post_data = jsonMode ? post_data_object.to_json : objectToString(post_data_object)
    req.body = post_data

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) { |http| http.request(req) }
  end

  def self.objectToString(object, separator = '&')
    object.map { |key, value| "#{escape(key)}=#{escape(value)}" }.join(separator)
  end

  def self.escape(value)
    URI.encode_www_form_component(value)
  end

  def self.valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError => e
    false
  end
end
