ENV['RAILS_ENV'] = 'test'
ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'

require 'rubygems'
require 'bundler'

Bundler.setup

require 'active_record'
require 'action_controller'
require 'action_mailer'
require 'rails'

Rails.env = 'test'

require 'solidus_core'

Bundler.require(:default, :test)

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

class ApplicationRecord < ActiveRecord::Base
end

class ApplicationMailer < ActionMailer::Base
end

module ApplicationHelper
end

module DummyApp
  def self.gem_root
    Pathname.new(File.dirname(ENV['BUNDLE_GEMFILE']))
  end

  def self.rails_root
    Pathname.new(gem_root).join('spec', 'dummy')
  end

  class Application < ::Rails::Application
    config.root                                       = DummyApp.rails_root
    config.eager_load                                 = false
    config.cache_classes                              = true
    config.cache_store                                = :memory_store
    config.serve_static_assets                        = true
    config.public_file_server.headers                 = { 'Cache-Control' => 'public, max-age=3600' }
    config.whiny_nils                                 = true
    config.consider_all_requests_local                = true
    config.action_controller.perform_caching          = false
    config.action_dispatch.show_exceptions            = false
    config.active_support.deprecation                 = :stderr
    config.action_mailer.delivery_method              = :test
    config.action_controller.allow_forgery_protection = false
    config.active_support.deprecation                 = :stderr
    config.secret_token                               = 'SECRET_TOKEN'
    config.secret_key_base                            = 'SECRET_TOKEN'

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
      config.assets.paths << File.expand_path('../dummy_app/assets/javascripts', __FILE__)
      config.assets.paths << File.expand_path('../dummy_app/assets/stylesheets', __FILE__)
    end

    config.paths["config/database"] = File.expand_path('../dummy_app/database.yml', __FILE__)
    config.paths['app/views'] = File.expand_path('../dummy_app/views', __FILE__)

    ActionMailer::Base.default from: "store@example.com"
  end
end

require 'spree/testing_support/dummy_app/migrations'

DummyApp::Application.initialize!

DummyApp::Application.routes.draw do
  mount Spree::Core::Engine, at: '/'
end

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

Spree.user_class = 'Spree::LegacyUser'
Spree.config do |config|
  config.mails_from = "store@example.com"
end
