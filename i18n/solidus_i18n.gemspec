# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solidus_i18n/version'

Gem::Specification.new do |spec|
  spec.name        = 'solidus_i18n'
  spec.version     = SolidusI18n.version
  spec.authors = ['Thomas von Deyen']
  spec.email       = ['tvd@magiclabs.de']

  spec.summary     = 'Provides locale information for use in Solidus.'
  spec.description = 'A collection of translations for Solidus.'
  spec.homepage    = 'https://solidus.io'
  spec.license     = 'BSD-3-Clause'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'solidus_core', ['>= 1.1', '< 3']

  spec.add_development_dependency 'pry-rails', '~> 0.3.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.1'
  spec.add_development_dependency 'rubocop', '~> 0.67.2'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
