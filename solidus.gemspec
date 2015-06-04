# encoding: UTF-8
version = File.read(File.expand_path('../SOLIDUS_VERSION',__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus'
  s.version     = version
  s.summary     = 'Full-stack e-commerce framework for Ruby on Rails.'
  s.description = 'Spree is an open source e-commerce framework for Ruby on Rails.  Join us on the spree-user google group or in #spree on IRC'

  s.files        = Dir['README.md', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'
  s.required_ruby_version     = '>= 2.1.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.author       = 'Solidus Team'
  s.email        = 'contact@solidus.io'
  s.homepage     = 'http://solidus.io'
  s.license      = %q{BSD-3}

  s.add_dependency 'solidus_core', version
  s.add_dependency 'solidus_api', version
  s.add_dependency 'solidus_backend', version
  s.add_dependency 'solidus_frontend', version
  s.add_dependency 'solidus_sample', version
end
