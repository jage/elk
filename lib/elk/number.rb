module Elk
  class Number
    attr_reader :country, :sms_url, :number_id, :number, :capabilities

    def initialize(parameters)
      @country = parameters[:country]
      @sms_url = parameters[:sms_url]
      @status  = parameters[:active]
      @number_id  = parameters[:id]
      @number  = parameters[:number]
      @capabilities = parameters[:capabilities]
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

    def self.numbers(parameters)
      account = parameters.delete(:account)

      response = account.get('/Numbers')

      JSON.parse(response.body, :symbolize_names => true)[:numbers].collect do |n|
        self.new(n)
      end
    end
  end
end