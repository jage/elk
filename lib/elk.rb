# External
require 'json/pure'
require 'open-uri'
require 'rest_client'
require 'time'
# Internal
require 'elk/number'
require 'elk/sms'

module Elk
  BASE_DOMAIN = 'api.46elks.com'
  API_VERSION = 'a1'
  VERSION = '0.0.3'

  class AuthError < RuntimeError; end
  class ServerError < RuntimeError; end
  class BadResponse < RuntimeError; end
  class BadRequest < RuntimeError; end

  class << self
    attr_accessor :username
    attr_accessor :password
    attr_accessor :base_domain

    def configure
      yield self
    end

    def base_url
      "https://#{username}:#{password}@#{(base_domain || BASE_DOMAIN)}/#{API_VERSION}"
    end

    def get(path, parameters = {})
      execute(:get, path, parameters)
    end

    def post(path, parameters = {})
      execute(:post, path, parameters)
    end

    def execute(method, path, parameters, headers={:accept => :json}, &block)
      payload = {}.merge(parameters)
      url = base_url + path
      RestClient::Request.execute(:method => method, :url => url, :payload => payload, :headers => headers, &block)
    rescue RestClient::Unauthorized
      raise AuthError, "Authentication failed"
    rescue RestClient::InternalServerError
      raise ServerError, "Server error"
    rescue RestClient::Forbidden => e
      raise BadRequest, e.http_body
    end

    def parse_json(body)
      JSON.parse(body, :symbolize_names => true)
    rescue JSON::ParserError
      raise BadResponse, "Can't parse JSON"
    end
  end
end