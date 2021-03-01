require 'rubygems'
gemfile = File.expand_path(__dir__)

ENV['BUNDLE_GEMFILE'] = gemfile
require 'bundler'
Bundler.setup
