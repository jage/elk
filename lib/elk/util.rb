module Elk
  module Util
    def verify_parameters(parameters, required_parameters)
      missing_parameters = (required_parameters - parameters.keys)
      unless missing_parameters.empty?
        raise Elk::MissingParameter, "Requires #{missing_parameters.collect {|s| ":#{s}"}.join(', ')} parameters"
      end    
    end
  end
end