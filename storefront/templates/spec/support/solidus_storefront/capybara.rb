# frozen_string_literal: true

require "selenium/webdriver"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "spree/testing_support/capybara_ext"

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do |example|
    screen_size = example.metadata[:screen_size] || [1800, 1400]
    using = (ENV["CAPYBARA_DRIVER"] == "selenium") ? :firefox : :headless_firefox

    driven_by(:selenium, using: using, screen_size: screen_size)
  end
end
