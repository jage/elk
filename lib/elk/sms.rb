module Elk
  # Used to send SMS through 46elks SMS-gateway
  class SMS
    attr_reader :from, :to, :message, :message_id, :created_at, 
                :loaded_at, :direction, :status #:nodoc:

    def initialize(parameters) #:nodoc:
      set_parameters(parameters)
    end

    def set_parameters(parameters) #:nodoc:
      @from       = parameters[:from]
      @to         = parameters[:to]
      @message    = parameters[:message]
      @message_id = parameters[:id]      
      @created_at = Time.parse(parameters[:created])
      @loaded_at  = Time.now
      @direction  = parameters[:direction]
      @status     = parameters[:status]
    end

    # Reloads a SMS from server
    def reload
      response = Elk.get("/SMS/#{self.message_id}")
      self.set_parameters(Elk.parse_json(response.body))
      response.code == 200
    end

    class << self
      include Elk::Util
      
      # Send SMS
      # Required parameters
      #
      # * :from - Either the one of the allocated numbers or arbitrary alphanumeric string of at most 11 characters
      # * :to - Any phone number capable of receiving SMS
      # * :message - Any UTF-8 text Splitting and joining multi-part SMS messages are automatically handled by the API
      def send(parameters)
        verify_parameters(parameters, [:from, :message, :to])

        # Warn if the from string will be capped by the sms gateway
        if parameters[:from] && parameters[:from].match(/^(\w{11,})$/)
          warn "SMS 'from' value #{parameters[:from]} will be capped at 11 chars"
        end

        response = Elk.post('/SMS', parameters)
        self.new(Elk.parse_json(response.body))
      end

      # Get outgoing and incomming messages. Limited by the API to 100 latest
      def all
        response = Elk.get('/SMS')
        Elk.parse_json(response.body)[:data].collect do |n|
          self.new(n)
        end
      end
    end
  end
end
