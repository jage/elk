module Elk
  class SMS
    attr_reader :from, :to, :message, :message_id, :created_at, :loaded_at

    def initialize(parameters)
      set_parameters(parameters)
    end

    def set_parameters(parameters)
      @from = parameters[:from]
      @to = parameters[:to]
      @message = parameters[:message]
      @message_id = parameters[:id]
      @created_at = Time.parse(parameters[:created])
      @loaded_at = Time.now
    end

    def reload
      response = Elk.get("/SMS/#{self.message_id}")
      self.set_parameters(JSON.parse(response.body, :symbolize_names => true))
      response.code == 200
    end

    class << self
      def send(settings)
        parameters = {}.merge(settings)
        response = Elk.post('/SMS', parameters)

        self.new(JSON.parse(response.body, :symbolize_names => true))
      end

      def all
        response = Elk.get('/SMS')

        JSON.parse(response.body, :symbolize_names => true)[:smses].collect do |n|
          self.new(n)
        end
      end

    end
  end
end
