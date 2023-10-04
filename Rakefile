# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_tasks'

task default: :spec

def print_title(gem_name = '')
  title = ["Solidus", gem_name].join(' ').strip
  puts "\n#{'-' * title.size}\n#{title}\n#{'-' * title.size}"
end

def subproject_task(project, task, title: project, task_name: nil)
  task_name ||= "#{task}:#{project}"
  task task_name do
    print_title(title)
    Dir.chdir("#{File.dirname(__FILE__)}/#{project}") do
      sh "rake #{task}"
    end
  end
end

%w[spec db:drop db:create db:migrate db:reset].each do |task|
  %w(api backend core frontend sample).each do |project|
    desc "Run specs for #{project}" if task == 'spec'
    subproject_task(project, task)
  end

  desc "Run rake #{task} for each Solidus engine"
  task task => %w(api backend core frontend sample).map { |p| "#{task}:#{p}" }
end

desc "Run backend JS specs"
subproject_task("backend", "spec:js", title: "backend JS", task_name: "spec:backend:js")

# Add backend JS specs to `rake spec` dependencies
task spec: 'spec:backend:js'

task test: :spec
task test_app: 'db:reset'

desc "clean the whole repository by removing all the generated files"
task :clean do
  rm_f  "Gemfile.lock"
  rm_rf "sandbox"
  rm_rf "pkg"

  %w(api backend core frontend sample).each do |gem_name|
    print_title(gem_name)
    rm_f  "#{gem_name}/Gemfile.lock"
    rm_rf "#{gem_name}/pkg"
    rm_rf "#{gem_name}/spec/dummy"
  end
end

SOLIDUS_GEM_NAMES = %w[core api backend sample]
GEM_TASKS_NAME = %w[build install]

GEM_TASKS_NAME.each do |task_name|
  desc "Run rake gem:#{task} for each Solidus gem"
  task task_name do
    SOLIDUS_GEM_NAMES.each do |gem_name|
      cd(gem_name) { sh "rake #{task_name}" }
    end
  end
end

task :releasez do
  require_relative 'core/lib/spree/core/version'
  SOLIDUS_GEM_NAMES.each do |gem_name|
    sh "gem push #{gem_name}/pkg/solidus_#{gem_name}-#{Spree.solidus_version}.gem"
  end
end

namespace :solidus do
  desc "Report code coverage results for all solidus gems"
  task :coverage, [:formatter] do |task, args|
    require "simplecov"
    SimpleCov.merge_timeout 3600
    if ENV["COVERAGE_DIR"]
      SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
    end
    if args[:formatter] == "cobertura"
      require "simplecov-cobertura"
      SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
    end
    SimpleCov.result.format!
  end
end
