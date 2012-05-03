require 'rake'
require 'rake/testtask'
require 'rbconfig'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new("spec:translations") do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'i18n-spec/tasks' # needs to be loaded after rspec

task :default => :spec
