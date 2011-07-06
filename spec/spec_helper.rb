require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'webmock/rspec'

def fixture_path
  File.expand_path(File.join('..', 'fixtures'), __FILE__)
end

def fixture(file)
  File.new(File.join(fixture_path, file))
end