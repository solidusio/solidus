# frozen_string_literal: true

require "rubygems"
require "rake"
require "rake/testtask"
require "rspec/core/rake_task"
require "solidus_legacy_promotions"
require "spree/testing_support/dummy_app/rake_tasks"
require "solidus_admin/testing_support/dummy_app/rake_tasks"
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new
task default: :spec

DummyApp::RakeTasks.new(
  gem_root: File.dirname(__FILE__),
  lib_name: "solidus_friendly_promotions"
)

task test_app: "db:reset"
