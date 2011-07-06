require 'rake'

desc "Run specs"
task :spec do
  sh('bundle install')
  require 'rubygems'
  require 'bundler/setup'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w(-fs -c)
  end
end

desc "Synonym for spec"
task :test => :spec
desc "Synonym for spec"
task :tests => :spec
task :default => :spec