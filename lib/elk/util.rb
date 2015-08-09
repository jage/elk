module Elk
  module Util
    def verify_parameters(parameters, required_parameters)
      missing_parameters = (required_parameters - parameters.keys)
      unless missing_parameters.empty?
        message = missing_parameters.collect { |s| ":#{s}" }.join(', ')
        raise Elk::MissingParameter, "Requires #{message} parameters"
      end
    end
  end
end
