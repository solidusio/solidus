# frozen_string_literal: true

require 'selenium/webdriver'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'spree/testing_support/capybara_ext'

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by((ENV['CAPYBARA_DRIVER'] || :rack_test).to_sym)
  end

  config.before(:each, type: :system, js: true) do |example|
    screen_size = example.metadata[:screen_size] || [1800, 1400]
    driven_by(:selenium, using: :headless_chrome, screen_size: screen_size) do |capabilities|
      capabilities.add_argument("--disable-search-engine-choice-screen")
    end
  end
end

Capybara.register_driver :selenium_chrome_headless_docker_friendly do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--disable-search-engine-choice-screen'
  # Sandbox cannot be used inside unprivileged Docker container
  browser_options.args << '--no-sandbox'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
