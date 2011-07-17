module Elk
  class SMS
    attr_reader :from, :to, :message, :message_id, :created_at

    def initialize(parameters)
      @from = parameters[:from]
      @to = parameters[:to]
      @message = parameters[:message]
      @message_id = parameters[:id]
      @created_at = DateTime.parse(parameters[:created])
    end

    class << self
      def send(settings)
        parameters = {}.merge(settings)
        response = Elk.post('/SMS', parameters)

        JSON.parse(response.body, :symbolize_names => true)
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
