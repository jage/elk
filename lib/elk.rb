# External
require 'json/pure'
require 'open-uri'
require 'rest_client'
# Internal
require 'elk/account'
require 'elk/number'
require 'elk/sms'

module Elk
  BASE_PROTOCOL = 'https'
  BASE_DOMAIN = 'api.46elks.com'
  API_VERSION = 'a1'
  VERSION = '0.0.1'

  def self.base_url(username, password, base_domain = nil)
    "#{BASE_PROTOCOL}://#{username}:#{password}@#{(base_domain || BASE_DOMAIN)}/#{API_VERSION}"
  end
end