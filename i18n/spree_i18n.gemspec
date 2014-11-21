Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_i18n'
  s.version     = '3.0.0'
  s.summary     = 'Provides locale information for use in Spree.'
  s.description = s.summary

  s.author      = 'Sean Schofield'
  s.email       = 'sean.schofield@gmail.com'
  s.homepage    = 'http://spreecommerce.com'
  s.license     = %q{BSD-3}

  s.rubyforge_project = 'spree_i18n'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_dependency 'rails-i18n', '~> 4.0.1'
  s.add_dependency 'spree_core', '~> 3.0.0.beta'
  s.add_dependency 'globalize', '~> 4.0.2'
  s.add_dependency 'i18n_data', '~> 0.5.1'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails', '~> 3.0.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.9'
  s.add_development_dependency 'coffee-rails', '~> 4.0.0'
  s.add_development_dependency 'sass-rails', '~> 4.0.0'
  s.add_development_dependency 'i18n-spec', '~> 0.5.2'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'capybara', '~> 2.4.1'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'poltergeist', '~> 1.5.0'
  s.add_development_dependency 'simplecov', '~> 0.9.0'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'pry'
end
