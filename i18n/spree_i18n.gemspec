Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_i18n'
  s.version     = '3.0.0'
  s.summary     = 'Provides locale information for use in Spree.'
  s.description = 'Provides locale information for use in Spree.'

  s.author      = 'Sean Schofield'
  s.email       = 'sean.schofield@gmail.com'
  s.homepage    = 'http://spreecommerce.com'
  s.rubyforge_project = 'spree_i18n'

  s.files        = Dir['LICENSE', 'README.md', 'default/**/*', 'config/**/*', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'rails-i18n', '~> 0.7.3'
  s.add_dependency 'spree_core', '~> 2.2.0.beta'
  s.add_dependency 'globalize', '~> 4.0.0'

  s.add_development_dependency 'rspec-rails', '~> 2.13'
  s.add_development_dependency 'sqlite3', '~> 1.3.7'
  s.add_development_dependency 'pry'
end
