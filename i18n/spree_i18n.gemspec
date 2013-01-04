Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_i18n'
  s.version     = '1.0.0'
  s.summary     = 'Provides locale information for use in Spree.'
  s.description = 'Provides locale information for use in Spree.'

  s.required_ruby_version = '>= 1.8.7'
  s.author      = 'Sean Schofield'
  s.email       = 'sean@railsdog.com'
  s.homepage    = 'http://spreecommerce.com'
  s.rubyforge_project = 'spree_i18n'

  s.files        = Dir['LICENSE', 'README.md', 'default/**/*', 'config/**/*', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'rails-i18n'
  s.add_dependency('spree',  '>= 1.1')
  s.add_dependency('i18n', '~> 0.5')
  s.add_development_dependency "rails", ">= 3.0.0"
  s.add_development_dependency "rspec-rails", ">= 2.7.0"
  s.add_development_dependency "i18n-spec", ">= 0.2"
  s.add_development_dependency "spork", "~> 1.0rc"
  s.add_development_dependency "sqlite3", "~> 1.3.6"
  s.add_development_dependency "i18n-spec"
end
