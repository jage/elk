# frozen_string_literal: true

module Elk
  # When the authentication can't be done
  class AuthError < RuntimeError; end

  # Raised when the API server isn't working
  class ServerError < RuntimeError; end

  # Generic exception when 46elks API gives a response Elk can't parse
  class BadResponse < RuntimeError; end

  # Generic exception when Elk calls 46elk API the wrong way
  class BadRequest < RuntimeError; end

  # Raised when required paremeters are omitted
  class MissingParameter < RuntimeError; end
end
