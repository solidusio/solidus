# encoding: UTF-8
version = File.read(File.expand_path("../../SOLIDUS_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_backend'
  s.version     = version
  s.summary     = 'backend e-commerce functionality for the Spree project.'
  s.description = 'Required dependency for Spree'

  s.required_ruby_version = '>= 2.1.0'
  s.author      = 'Solidus Team'
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.rubyforge_project = 'solidus_backend'

  s.files        = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*', 'vendor/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus_api', version
  s.add_dependency 'solidus_core', version

  s.add_dependency 'jquery-rails', '~> 3.1.2'
  s.add_dependency 'jquery-ui-rails', '~> 5.0.0'
  s.add_dependency 'select2-rails',   '3.5.9.1' # 3.5.9.2 breaks forms
end
