# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'solidus_i18n/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_i18n'
  s.version     = SolidusI18n.version
  s.summary     = 'Provides locale information for use in Solidus.'
  s.description = s.summary

  s.author      = 'Thomas von Deyen'
  s.email       = 'tvd@magiclabs.de'
  s.homepage    = 'https://solidus.io'
  s.license     = 'BSD-3'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_runtime_dependency 'solidus_core', ['>= 1.1', '< 3']

  s.add_development_dependency 'pry-rails', '>= 0.3.0'
  s.add_development_dependency 'rubocop', '>= 0.24.1'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'simplecov', '~> 0.9'
end
