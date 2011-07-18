$:.unshift File.expand_path("../lib", __FILE__)

spec = Gem::Specification.new do |s|
  s.name = "elk"
  s.version = "0.0.4"
  s.author = "Johan Eckerstroem"
  s.email = "johan@duh.se"
  s.summary = "Client library for 46elks SMS/MMS/Voice service."
  s.description = "Elk can be used to allocate a phone numbers, manage the numbers and send/recieve messages through these numbers."
  s.homepage = "https://github.com/jage/elk"

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.MD"]

  # elk dependencies
  s.add_dependency("json_pure", "~> 1.5.2")
  s.add_dependency("rest-client", "~> 1.6.3")

  # Tests
  s.add_development_dependency("rake", "~> 0.9.2")
  s.add_development_dependency("rspec", "~> 2.6.0")
  s.add_development_dependency("webmock", "~> 1.6.4")

  s.require_path = 'lib'
  s.files = Dir.glob("{lib,spec}/**/*")
end
