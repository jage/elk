require "json"

module Elk
  module Util
    def verify_parameters(parameters, required_parameters)
      missing_parameters = (required_parameters - parameters.keys)
      unless missing_parameters.empty?
        message = missing_parameters.map { |s| ":#{s}" }.join(', ')
        raise Elk::MissingParameter, "Requires #{message} parameters"
      end
    end

    # Wrapper around MultiJson.load, symbolize names
    def self.parse_json(body)
      JSON.parse(body, :symbolize_names => true)
    rescue JSON::ParserError
      raise BadResponse, "Can't parse JSON"
    end
  end
end
