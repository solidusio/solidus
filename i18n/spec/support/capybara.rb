require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'selenium/webdriver'

Capybara.javascript_driver = :selenium_chrome_headless
