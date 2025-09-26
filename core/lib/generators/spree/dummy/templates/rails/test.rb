Dummy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true
  config.public_file_server.headers = {"Cache-Control" => "public, max-age=3600"}

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  config.eager_load = false

  # Raise exceptions instead of rendering exception templates
  if Rails.gem_version >= Gem::Version.new("7.1")
    config.action_controller.raise_on_missing_callback_actions = true
    config.action_dispatch.show_exceptions = :none
  else
    config.action_dispatch.show_exceptions = false
  end

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  ActionMailer::Base.default from: "solidus@example.com"

  config.active_storage.service = :test

  # Raise on deprecation warnings
  if ENV["SOLIDUS_RAISE_DEPRECATIONS"].present?
    Spree.deprecator.behavior = :raise
  end
end
