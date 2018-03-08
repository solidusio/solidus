# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

# Teaspoon doesn't allow you to pass client driver options to the Selenium WebDriver. This monkey patch
# is a temporary fix until this PR is merged: https://github.com/jejacks0n/teaspoon/pull/519.
require 'teaspoon/driver/selenium'

Teaspoon::Driver::Selenium.class_eval do
  def run_specs(runner, url)
    driver = ::Selenium::WebDriver.for(driver_options[:client_driver], @options.except(:client_driver) || {})
    driver.navigate.to(url)

    ::Selenium::WebDriver::Wait.new(driver_options).until do
      done = driver.execute_script("return window.Teaspoon && window.Teaspoon.finished")
      driver.execute_script("return window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
        runner.process("#{line}\n")
      end
      done
    end
  ensure
    driver.quit if driver
  end
end

# Similar to setup described in
# https://github.com/jejacks0n/teaspoon/wiki/Micro-Applications

if defined?(DummyApp)
  DummyApp::Migrations.auto_migrate

  require 'teaspoon-mocha'

  Teaspoon.configure do |config|
    config.mount_at = "/teaspoon"
    config.root = Spree::Backend::Engine.root
    config.asset_paths = ["spec/javascripts", "spec/javascripts/stylesheets"]
    config.fixture_paths = ["spec/javascripts/fixtures"]

    config.driver = :selenium
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu window-size=1920,1440) }
    )
    config.driver_options = { client_driver: :chrome, desired_capabilities: capabilities }

    config.suite do |suite|
      suite.use_framework :mocha, "2.3.3"
      suite.matcher = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
      suite.helper = "spec_helper"
      suite.boot_partial = "/boot"
      suite.expand_assets = true
    end
  end
else
  require 'solidus_backend'

  require 'teaspoon'

  require 'spree/testing_support/dummy_app'

  DummyApp.setup(
    gem_root: File.expand_path('..', __dir__),
    lib_name: 'solidus_backend',
    auto_migrate: false
  )
end
