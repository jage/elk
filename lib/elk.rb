# External
require "multi_json"
require "open-uri"
require "rest_client"
require "time"
require "forwardable"

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

    extend Forwardable

    # Delegate methods to client
    %i(username username= password password= base_domain base_url get post execute).each do |method|
      def_delegator :client, method
    end

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
