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
      MultiJson.load(body, :symbolize_keys => true)
    rescue MultiJson::DecodeError
      raise BadResponse, "Can't parse JSON"
    end
  end
end
