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
      self.set_parameters(Elk.parse_json(response.body))
      response.code == 200
    end

    class << self
      def send(settings)
        parameters = {}.merge(settings)
        response = Elk.post('/SMS', parameters)

        self.new(Elk.parse_json(response.body))
      end

      def all
        response = Elk.get('/SMS')

        Elk.parse_json(response.body)[:smses].collect do |n|
          self.new(n)
        end
      end

    end
  end
end
