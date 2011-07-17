module Elk
  class SMS
    class << self
      def send(settings)
        parameters = {}.merge(settings)
        response = Elk.post('/SMS', parameters)

        JSON.parse(response.body, :symbolize_names => true)
      end
    end
  end
end
