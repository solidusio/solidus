# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_storage/engine'

Rails.env = 'test'

require 'solidus_core'

RAILS_6_OR_ABOVE = Rails.gem_version >= Gem::Version.new('6.0')

# @private
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# @private
class ApplicationRecord < ActiveRecord::Base
end

# @private
class ApplicationMailer < ActionMailer::Base
end

# @private
module ApplicationHelper
end

# @private
module DummyApp
  def self.setup(gem_root:, lib_name:, auto_migrate: true)
    ENV["LIB_NAME"] = lib_name
    DummyApp::Application.config.root = File.join(gem_root, 'spec', 'dummy')

    DummyApp::Application.initialize!

    if auto_migrate
      DummyApp::Migrations.auto_migrate
    end
  end

  class Application < ::Rails::Application
    config.load_defaults("#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}")
    # Make the test environment more production-like:
    config.cache_classes = true
    config.action_controller.allow_forgery_protection = false
    config.action_controller.default_protect_from_forgery = false
    config.action_mailer.perform_caching = false
    config.i18n.fallbacks = true

    # In the test environment, we use the `caching: true` RSpec metadata to
    # enable caching on select specs. See
    # core/lib/spree/testing_support/caching.rb. See also
    # https://github.com/solidusio/solidus/issues/4110
    config.action_controller.perform_caching = false

    # Make debugging easier:
    config.consider_all_requests_local = true
    config.action_dispatch.show_exceptions = false
    config.active_support.deprecation = :stderr
    config.log_level = :debug

    # Improve test suite performance:
    config.eager_load = false
    config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }
    config.cache_store = :memory_store

    # We don't use a web server, so we let Rails serve assets.
    config.public_file_server.enabled = true

    # We don't want to send email in the test environment.
    config.action_mailer.delivery_method = :test

    # No need to use credentials file in a test environment.
    config.secret_key_base = 'SECRET_TOKEN'

    # Set the preview path within the dummy app:
    config.action_mailer.preview_path = File.expand_path('dummy_app/mailer_previews', __dir__)

    config.active_record.sqlite3.represent_boolean_as_integer = true unless RAILS_6_OR_ABOVE
    config.active_record.dump_schema_after_migration = false

    # Configure active storage to use storage within tmp folder
    unless ENV['DISABLE_ACTIVE_STORAGE']
      initializer 'solidus.active_storage' do
        config.active_storage.service_configurations = {
          test: {
            service: 'Disk',
            root: Rails.root.join('tmp', 'storage')
          }
        }
        config.active_storage.service = :test
        config.active_storage.variant_processor = ENV.fetch('ACTIVE_STORAGE_VARIANT_PROCESSOR', :mini_magick).to_sym
      end
    end

    # Avoid issues if an old spec/dummy still exists
    config.paths['config/initializers'] = []
    config.paths['config/environments'] = []

    migration_dirs = Rails.application.migration_railties.flat_map do |engine|
      if engine.respond_to?(:paths)
        engine.paths['db/migrate'].to_a
      else
        []
      end
    end
    config.paths['db/migrate'] = migration_dirs
    ActiveRecord::Migrator.migrations_paths = migration_dirs

    config.assets.paths << File.expand_path('dummy_app/assets/javascripts', __dir__)
    config.assets.paths << File.expand_path('dummy_app/assets/stylesheets', __dir__)

    config.paths["config/database"] = File.expand_path('dummy_app/database.yml', __dir__)
    config.paths['app/views'] = File.expand_path('dummy_app/views', __dir__)
    config.paths['config/routes.rb'] = File.expand_path('dummy_app/routes.rb', __dir__)

    ActionMailer::Base.default from: "store@example.com"
  end
end

require 'spree/testing_support/dummy_app/migrations'

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

Spree.user_class = 'Spree::LegacyUser'
Spree.load_defaults(Spree.solidus_version)
Spree.config do |config|
  config.mails_from = "store@example.com"
  # TODO: Remove on Solidus 4.0 as it'll be the default
  require 'spree/event/adapters/deprecation_handler'
  if Spree::Event::Adapters::DeprecationHandler.legacy_adapter_set_by_env.nil?
    require 'spree/event/adapters/default'
    config.events.adapter = Spree::Event::Adapters::Default.new
  end

  if ENV['DISABLE_ACTIVE_STORAGE']
    config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
    config.taxon_attachment_module = 'Spree::Taxon::PaperclipAttachment'
  end
end

# Raise on deprecation warnings
if ENV['SOLIDUS_RAISE_DEPRECATIONS'].present?
  Spree::Deprecation.behavior = :raise
end
