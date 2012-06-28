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

require 'i18n-spec/tasks' # needs to be loaded after rspec

# Load any custom rakefiles for extension
Dir[ File.expand_path('lib/tasks/*.rake', File.dirname(__FILE__)) ].sort.each { |f| load f }

task :default => :spec
