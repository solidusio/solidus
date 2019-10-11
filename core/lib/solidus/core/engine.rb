# frozen_string_literal: true

require 'solidus/config'

module Solidus
  module Core
    class Engine < ::Rails::Engine
      CREDIT_CARD_NUMBER_PARAM = /payment.*source.*\.number$/
      CREDIT_CARD_VERIFICATION_VALUE_PARAM = /payment.*source.*\.verification_value$/

      isolate_namespace Solidus
      engine_name 'spree'

      config.generators do |g|
        g.test_framework :rspec
      end

      initializer "spree.environment", before: :load_config_initializers do |app|
        app.config.spree = Solidus::Config.environment
      end

      # leave empty initializers for backwards-compatability. Other apps might still rely on these events
      initializer "spree.default_permissions", before: :load_config_initializers do; end
      initializer "spree.register.calculators", before: :load_config_initializers do; end
      initializer "spree.register.stock_splitters", before: :load_config_initializers do; end
      initializer "spree.register.payment_methods", before: :load_config_initializers do; end
      initializer 'spree.promo.environment', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotion.calculators', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotion.rules', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotions.actions', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotions.shipping_actions', before: :load_config_initializers do; end

      # Filter sensitive information during logging
      initializer "spree.params.filter", before: :load_config_initializers do |app|
        app.config.filter_parameters += [
          %r{^password$},
          %r{^password_confirmation$},
          CREDIT_CARD_NUMBER_PARAM,
          CREDIT_CARD_VERIFICATION_VALUE_PARAM,
        ]
      end

      initializer "spree.core.checking_migrations", before: :load_config_initializers do |_app|
        Migrations.new(config, engine_name).check
      end

      # Setup Event Subscribers
      initializer 'spree.core.initialize_subscribers' do |app|
        app.reloader.to_prepare do
          Solidus::Event.subscribers.each(&:subscribe!)
        end

        app.reloader.before_class_unload do
          Solidus::Event.subscribers.each(&:unsubscribe!)
        end
      end

      # Load in mailer previews for apps to use in development.
      # We need to make sure we call `Preview.all` before requiring our
      # previews, otherwise any previews the app attempts to add need to be
      # manually required.
      if Rails.env.development?
        initializer "spree.mailer_previews" do
          ActionMailer::Preview.all
          Dir[root.join("lib/solidus/mailer_previews/**/*_preview.rb")].each do |file|
            require_dependency file
          end
        end
      end

      initializer 'solidus.core.namespace_migration' do
        config.to_prepare do
          Solidus::NamespaceMigration.activate
        end
      end
    end
  end
end
