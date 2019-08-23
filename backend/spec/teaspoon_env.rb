# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'teaspoon/driver/selenium'

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
    config.driver_options = {
      client_driver: :chrome,
      selenium_options: {
        options: Selenium::WebDriver::Chrome::Options.new(
          args: %w(headless disable-gpu window-size=1920,1440),
        ),
      },
    }

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
