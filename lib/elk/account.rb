module Elk
  class Account
    attr_reader :username, :password
    def initialize(settings = {})
      @username = settings[:username]
      @password = settings[:password]
    end

    def base_url
      Elk.base_url(@username, @password)
    end

    def get(path, parameters = {})
      parameters = {}.merge(parameters)
      url = base_url + path

      RestClient.get(url, parameters, {:accept => :json})
    end

    def post(path, parameters = {})
      parameters = {}.merge(parameters)
      url = base_url + path

      RestClient.post(url, parameters, {:accept => :json})
    end
  end
end