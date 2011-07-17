# External
require 'json/pure'
require 'open-uri'
require 'rest_client'
# Internal
require 'elk/number'
require 'elk/sms'

module Elk
  BASE_DOMAIN = 'api.46elks.com'
  API_VERSION = 'a1'
  VERSION = '0.0.2'

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
      parameters = {}.merge(parameters)
      url = base_url + path

      RestClient.get(url, {:accept => :json})
    end

    def post(path, parameters = {})
      parameters = {}.merge(parameters)
      url = base_url + path

      RestClient.post(url, parameters, {:accept => :json})
    end
  end
end