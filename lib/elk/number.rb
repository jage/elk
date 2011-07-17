module Elk
  class Number
    attr_reader :number_id, :number, :capabilities
    attr_accessor :country, :sms_url

    def initialize(parameters)
      @country = parameters[:country]
      @sms_url = parameters[:sms_url]
      @status  = parameters[:active]
      @number_id  = parameters[:id]
      @number = parameters[:number]
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

    def save
      response = Elk.post("/Numbers/#{self.number_id}", {:country => self.country, :sms_url => self.sms_url})

      response.code == 200
    end

    class << self
      def allocate(parameters)
        response = Elk.post('/Numbers', parameters)

        self.new(JSON.parse(response.body, :symbolize_names => true))
      end

      def all
        response = Elk.get('/Numbers')

        JSON.parse(response.body, :symbolize_names => true)[:numbers].collect do |n|
          self.new(n)
        end
      end
    end
  end
end