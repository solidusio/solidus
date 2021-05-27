# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_i18n/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_i18n'
  s.version     = SolidusI18n::VERSION
  s.summary     = 'Provides locale information for use in Solidus.'
  s.description = 'A collection of translations for Solidus.'

  s.required_ruby_version = '>= 2.5.0'

  s.author   = 'Thomas von Deyen'
  s.email    = 'tvd@magiclabs.de'
  s.homepage = 'https://github.com/solidusio/solidus_i18n'
  s.license  = 'BSD-3-Clause'

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.test_files = Dir['spec/**/*']
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  if s.respond_to?(:metadata)
    s.metadata["homepage_uri"] = s.homepage if s.homepage
    s.metadata["source_code_uri"] = s.homepage if s.homepage
  end

  s.add_runtime_dependency 'solidus_core', ['>= 1.1', '< 4']
  s.add_runtime_dependency 'solidus_support', '~> 0.4'

  s.add_development_dependency 'solidus_dev_support'
end
