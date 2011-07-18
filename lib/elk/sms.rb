module Elk
  class SMS
    attr_reader :from, :to, :message, :message_id, :created_at, :loaded_at

    def initialize(parameters)
      set_parameters(parameters)
    end

    def set_parameters(parameters)
      @from       = parameters[:from]
      @to         = parameters[:to]
      @message    = parameters[:message]
      @message_id = parameters[:id]
      @created_at = Time.parse(parameters[:created])
      @loaded_at  = Time.now
    end

    def reload
      response = Elk.get("/SMS/#{self.message_id}")
      self.set_parameters(Elk.parse_json(response.body))
      response.code == 200
    end

    class << self
      def send(parameters)
        parameters.require_keys!([:from, :message, :to])

        # Warn if the from string will be capped by the sms gateway
        if parameters[:from] && parameters[:from].match(/^(\w{11,})$/)
          warn "SMS 'from' value #{parameters[:from]} will be capped at 11 chars"
        end

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
