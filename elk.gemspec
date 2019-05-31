# frozen_string_literal: true

$:.unshift File.expand_path("../lib", __FILE__)

require 'elk/version'

spec = Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "elk"
  s.version     = Elk::VERSION
  s.author      = "Johan Eckerström"
  s.email       = "johan@duh.se"
  s.summary     = "Client library for 46elks SMS/MMS/Voice service."
  s.description = "Elk can be used to allocate a phone numbers, manage the numbers and send SMS through these numbers."
  s.homepage    = "https://github.com/jage/elk"

  s.requirements << 'API account at 46elks.com'

  s.license = 'MIT'

  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.MD", "MIT-LICENSE"]

  s.required_ruby_version = ">= 2.3.0"

  # elk dependencies
  s.add_dependency("rest-client", "~> 2.0")

  # Tests
  s.add_development_dependency("rake", "~> 10.0")
  s.add_development_dependency("rspec", "~> 3.0")
  s.add_development_dependency("webmock", "~> 2.0")

  s.require_path = 'lib'
  s.files = %w(README.MD MIT-LICENSE) + Dir["{lib,spec}/**/*"]
end
