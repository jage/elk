require 'rspec'
require 'webmock/rspec'

def fixture_path
  File.expand_path(File.join('..', 'fixtures'), __FILE__)
end

def fixture(file)
  File.new(File.join(fixture_path, file))
end

def configure_elk
  Elk.configure do |config|
    config.username = 'USERNAME'
    config.password = 'PASSWORD'
  end
end

def get_headers
  { "Accept" => "application/json" }
end

def post_headers
  { "Accept" => "application/json", "Content-Type" => "application/x-www-form-urlencoded" }
end
