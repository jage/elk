module Elk
  class Client
    # API Username from 46elks.com
    attr_accessor :username
    # API Password from 46elks.com
    attr_accessor :password

    def initialize(username: nil, password: nil)
      @username = username
      @password = password
    end
  end
end
