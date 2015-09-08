# External
require "multi_json"
require "open-uri"
require "rest_client"
require "time"

# Base module
# Used for to configure username and password through Elk.configure
module Elk
  # Base domain for 46elks API
  BASE_DOMAIN = "api.46elks.com"
  # API version supported
  API_VERSION = "a1"

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
    # Defaults to Elk::BASE_DOMAIN, but can be overriden for testing
    attr_accessor :base_domain

    # Set up authentication credentials, has to be done before using Elk::Number and Elk::SMS
    #
    #   Elk.configure do |config|
    #     config.username = "USERNAME"
    #     config.password = "PASSWORD"
    #   end
    def configure
      yield client
    end

    # Not thread safe
    def client
      @client ||= Client.new
    end

    def username
      client.username
    end

    def username=(user)
      client.username = user
    end

    def password
      client.password
    end

    def password=(passwd)
      client.password = passwd
    end

    # Base URL used for calling 46elks API
    def base_url
      unless username && password
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
    def execute(method, path, parameters, headers = { accept: :json }, &block)
      payload = {}.merge(parameters)
      url = base_url + path

      request_arguments = {
        method:  method,
        url:     url,
        payload: payload,
        headers: headers
      }

      RestClient::Request.execute(request_arguments, &block)
    rescue RestClient::Unauthorized
      raise AuthError, "Authentication failed"
    rescue RestClient::InternalServerError
      raise ServerError, "Server error"
    rescue RestClient::Forbidden => e
      raise BadRequest, e.http_body
    end

    # Wrapper around MultiJson.load, symbolize names
    def parse_json(body)
      MultiJson.load(body, :symbolize_keys => true)
    rescue MultiJson::DecodeError
      raise BadResponse, "Can't parse JSON"
    end
  end
end

# Internal
require_relative "elk/util"
require_relative "elk/version"
require_relative "elk/client"
require_relative "elk/number"
require_relative "elk/sms"
