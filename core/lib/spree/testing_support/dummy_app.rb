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
    root = Pathname(gem_root).join('spec/dummy')
    root.join("app/assets/config").mkpath
    root.join("app/assets/config/manifest.js").write("// Intentionally empty\n")

    DummyApp::Application.config.root = root
    DummyApp::Application.initialize! unless DummyApp::Application.initialized?

    if auto_migrate
      DummyApp::Migrations.auto_migrate
    end
  end

  class Application < ::Rails::Application
    config.load_defaults("#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}")

    if Rails.gem_version >= Gem::Version.new('7.1')
      config.action_controller.raise_on_missing_callback_actions = true
      config.action_dispatch.show_exceptions = :none
    end

    # Make the test environment more production-like:
    config.action_controller.allow_forgery_protection = false
    config.action_controller.default_protect_from_forgery = false
    config.action_mailer.perform_caching = false
    config.i18n.fallbacks = true

    # In the test environment, we use the `caching: true` RSpec metadata to
    # enable caching on select specs. See
    # core/lib/spree/testing_support/caching.rb. See also
    # https://github.com/solidusio/solidus/issues/4110
    config.action_controller.perform_caching = false

    # It needs to be explicitly set from Rails 7
    # https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0-spring
    config.cache_classes = true

    # Make debugging easier:
    config.consider_all_requests_local = true
    config.action_dispatch.show_exceptions = false # Should be :none for Rails 7.1+
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
    if ActionMailer::Base.respond_to? :preview_paths # Rails 7.1+
      config.action_mailer.preview_paths << File.expand_path('dummy_app/mailer_previews', __dir__)
    else
      config.action_mailer.preview_path = File.expand_path('dummy_app/mailer_previews', __dir__)
    end

    config.active_record.dump_schema_after_migration = false

    # Configure active storage to use storage within tmp folder
    initializer 'solidus.active_storage' do
      config.active_storage.service_configurations = {
        test: {
          service: 'Disk',
          root: Rails.root.join('tmp', 'storage')
        }
      }
      config.active_storage.service = :test
      config.active_storage.variant_processor = ENV.fetch('ACTIVE_STORAGE_VARIANT_PROCESSOR', :vips).to_sym
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
    ActiveRecord::Migration.verbose = false

    config.assets.paths << File.expand_path('dummy_app/assets/javascripts', __dir__)
    config.assets.paths << File.expand_path('dummy_app/assets/stylesheets', __dir__)
    config.assets.css_compressor = nil

    config.paths["config/database"] = File.expand_path('dummy_app/database.yml', __dir__)
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
  if (ENV['DISABLE_ACTIVE_STORAGE'] == 'true')
    config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
    config.taxon_attachment_module = 'Spree::Taxon::PaperclipAttachment'
  end
end

# Raise on deprecation warnings
if ENV['SOLIDUS_RAISE_DEPRECATIONS'].present?
  Spree.deprecator.behavior = :raise
end
