module Elk
  class Client
    # API Username from 46elks.com
    attr_accessor :username
    # API Password from 46elks.com
    attr_accessor :password
    # Used to overrid Elk::BASE_DOMAIN (in tests)
    attr_accessor :base_domain

    def initialize(username: nil, password: nil)
      @username = username
      @password = password
    end

    # Set authentication credentials
    #
    #   client = Elk::Client.new
    #   client.configure do |config|
    #     config.username = "USERNAME"
    #     config.password = "PASSWORD"
    #   end
    def configure
      yield self
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
  end
end
