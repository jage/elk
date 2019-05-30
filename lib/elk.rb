# frozen_string_literal: true

require "forwardable"

# Base module
# Used for to configure username and password through Elk.configure
module Elk
  class << self
    extend Forwardable

    # Delegate methods to client
    delegated_methods = [
      :username,
      :username=,
      :password,
      :password=,
      :base_domain,
      :base_url,
      :get,
      :post,
      :execute,
    ]

    delegated_methods.each do |method|
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
  end
end

# Internal
require_relative "elk/util"
require_relative "elk/error"
require_relative "elk/version"
require_relative "elk/client"
require_relative "elk/number"
require_relative "elk/sms"
