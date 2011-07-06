module Elk
  class Number
    attr_reader :country, :sms_url

    def initialize(parameters)
      @country = parameters[:country]
      @sms_url = parameters[:sms_url]
      @status  = parameters[:active]
    end

    def status
      case @status
      when 'yes'
        :active
      else
        nil
      end
    end

    def self.allocate(parameters)
      account = parameters.delete(:account)

      response = account.post('/Numbers', parameters)

      self.new(JSON.parse(response.body, :symbolize_names => true))
    end
  end
end