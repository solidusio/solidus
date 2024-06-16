# frozen_string_literal: true

require "rubygems"
require "rake"
require "rake/testtask"
require "rspec/core/rake_task"
require "spree/testing_support/dummy_app/rake_tasks"
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new
task default: :spec

DummyApp::RakeTasks.new(
  gem_root: File.dirname(__FILE__),
  lib_name: "solidus_friendly_promotions"
)

task test_app: "db:reset"
