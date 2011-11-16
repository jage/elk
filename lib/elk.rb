# External
require 'json/pure'
require 'open-uri'
require 'rest_client'
require 'time'

# Base module
# Used for to configure username and password through Elk.configure
module Elk
  # Base domain for 46elks API
  BASE_DOMAIN = 'api.46elks.com'
  # API version supported
  API_VERSION = 'a1'
  # Elk version
  VERSION     = '0.0.6'

  # When the authentication can't be done
  class AuthError < RuntimeError; end
  # Raised when the API server isn't working
  class ServerError < RuntimeError; end
  # Generic exception when 46elks API gives a response Elk can't parse
  class BadResponse < RuntimeError; end
  # Generic exception when Elk calls 46elk API the wrong way
  class BadRequest < RuntimeError; end
  # Raised when required paremeters are omitted
  class MissingParameter < RuntimeError; end

  class << self
    # API Username from 46elks.com
    attr_accessor :username
    # API Password from 46elks.com
    attr_accessor :password
    # Defaults to Elk::BASE_DOMAIN, but can be overriden for testing
    attr_accessor :base_domain

    # Set up authentication credentials, has to be done before using Elk::Number and Elk::SMS
    #
    #   Elk.configure do |config|
    #     config.username = 'USERNAME'
    #     config.password = 'PASSWORD
    #   end
    def configure
      yield self
    end

    # Base URL used for calling 46elks API
    def base_url
      if not username or not password
        raise AuthError, "API username and password required"
      end

      "https://#{username}:#{password}@#{(base_domain || BASE_DOMAIN)}/#{API_VERSION}"
    end

    # Wrapper for Elk.execute(:get)
    def get(path, parameters = {})
      execute(:get, path, parameters)
    end

    # Wrapper for Elk::execute(:post)
    def post(path, parameters = {})
      execute(:post, path, parameters)
    end

    # Wrapper around RestClient::RestClient.execute
    #
    # * Sets accept header to json
    # * Handles some exceptions
    #
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

    # Wrapper around JSON.parse, symbolize names
    def parse_json(body)
      JSON.parse(body, :symbolize_names => true)
    rescue JSON::ParserError
      raise BadResponse, "Can't parse JSON"
    end
  end
end

# --
# TODO: Not that nice to create methods in Hash
# --
class Hash #:nodoc: all
  def require_keys!(required_keys)
    unless (missing_parameters = required_keys - self.keys).empty?
      raise Elk::MissingParameter, "Requires #{missing_parameters.collect {|s| ":#{s}"}.join(', ')} parameters"
    end
  end
end

# Internal
require 'elk/number'
require 'elk/sms'
