# frozen_string_literal: true

require "selenium/webdriver"
require "capybara-screenshot"

Capybara::Screenshot.register_driver(:selenium_headless) do |driver, path|
  driver.browser.save_screenshot(path)
end
Capybara.javascript_driver = (ENV['CAPYBARA_DRIVER'] || :selenium_headless).to_sym
