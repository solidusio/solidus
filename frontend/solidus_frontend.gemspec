# encoding: UTF-8
version = File.read(File.expand_path("../../SOLIDUS_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_frontend'
  s.version     = version
  s.summary     = 'Cart and storefront for the Solidus e-commerce project.'
  s.description = s.summary

  s.required_ruby_version = '>= 2.1.0'
  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io/'
  s.rubyforge_project = 'solidus_frontend'

  s.files        = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus_api', version
  s.add_dependency 'solidus_core', version

  s.add_dependency 'canonical-rails', '~> 0.0.4'
  s.add_dependency 'jquery-rails'

  s.add_development_dependency 'capybara-accessible'
end
