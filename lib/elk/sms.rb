module Elk
  class SMS
    class << self
      def send(settings)
        account = settings.delete(:account)
        parameters = {}.merge(settings)
        response = account.post('/SMS', parameters)

        JSON.parse(response.body, :symbolize_names => true)
      end
    end
  end
end
