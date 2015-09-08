require 'bundler/gem_tasks'

desc "Run specs"
task :spec do
  begin
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec)
  rescue LoadError
  end
end

desc "Synonym for spec"
task :test => :spec
desc "Synonym for spec"
task :tests => :spec
task :default => :spec
