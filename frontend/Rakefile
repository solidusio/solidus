# frozen_string_literal: true

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'spree/testing_support/dummy_app/rake_tasks'

RSpec::Core::RakeTask.new
task default: :spec

DummyApp::RakeTasks.new(
  gem_root: File.expand_path(__dir__),
  lib_name: 'solidus_frontend'
)

task test_app: 'db:reset'
