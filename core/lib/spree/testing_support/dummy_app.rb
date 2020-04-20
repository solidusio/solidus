# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

Rails.env = 'test'

require 'solidus_core'

RAILS_6_OR_ABOVE = Rails.gem_version >= Gem::Version.new('6.0')

# @private
class ApplicationController < ActionController::Base
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
    config.eager_load = false
    config.cache_classes = true
    config.cache_store = :memory_store
    config.serve_static_assets = true
    config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }
    config.whiny_nils = true
    config.consider_all_requests_local = true
    config.action_controller.allow_forgery_protection = true
    config.action_controller.default_protect_from_forgery = true
    config.action_controller.perform_caching = false
    config.action_dispatch.show_exceptions = false
    config.active_support.deprecation = :stderr
    config.action_mailer.delivery_method = :test
    config.active_support.deprecation = :stderr
    config.secret_key_base = 'SECRET_TOKEN'

    unless RAILS_6_OR_ABOVE
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end

    config.storage_path = Rails.root.join('tmp', 'storage')

    if ENV['ENABLE_ACTIVE_STORAGE']
      initializer 'solidus.active_storage' do
        config.active_storage.service_configurations = {
          test: {
            service: 'Disk',
            root: config.storage_path
          }
        }
        config.active_storage.service = :test
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

    config.action_controller.include_all_helpers = false

    if config.respond_to?(:assets)
      config.assets.paths << File.expand_path('dummy_app/assets/javascripts', __dir__)
      config.assets.paths << File.expand_path('dummy_app/assets/stylesheets', __dir__)
    end

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
Spree.config do |config|
  config.mails_from = "store@example.com"
  config.raise_with_invalid_currency = false
  config.use_combined_first_and_last_name_in_address = true

  if ENV['ENABLE_ACTIVE_STORAGE']
    config.image_attachment_module = 'Spree::Image::ActiveStorageAttachment'
    config.taxon_attachment_module = 'Spree::Taxon::ActiveStorageAttachment'
  end
end

# Raise on deprecation warnings
if ENV['SOLIDUS_RAISE_DEPRECATIONS'].present?
  Spree::Deprecation.behavior = :raise
end
