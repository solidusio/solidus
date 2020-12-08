# frozen_string_literal: true

require 'spree/config'

module Spree
  module Core
    class Engine < ::Rails::Engine
      CREDIT_CARD_NUMBER_PARAM = /payment.*source.*\.number$/
      CREDIT_CARD_VERIFICATION_VALUE_PARAM = /payment.*source.*\.verification_value$/

      isolate_namespace Spree
      engine_name 'spree'

      config.generators do |generator|
        generator.test_framework :rspec
      end

      initializer "spree.environment", before: :load_config_initializers do |app|
        app.config.spree = Spree::Config.environment
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
          Spree::Event.activate_autoloadable_subscribers
        end

        app.reloader.before_class_unload do
          Spree::Event.deactivate_all_subscribers
        end
      end

      config.after_initialize do
        if Spree::Config.raise_with_invalid_currency == true
          Spree::Deprecation.warn(
            'Spree::Config.raise_with_invalid_currency set to true is ' \
            'deprecated. Please note that by switching this value, ' \
            'Spree::LineItem::CurrencyMismatch will not be raised anymore.',
            caller
          )
        end
        if Spree::Config.consider_actionless_promotion_active == true
          Spree::Deprecation.warn(
            'Spree::Config.consider_actionless_promotion_active set to true is ' \
            'deprecated. Please note that by switching this value, ' \
            'promotions with no actions will be considered active.',
            caller
          )
        end
        if Spree::Config.run_order_validations_on_order_updater != true
          Spree::Deprecation.warn(
            'Spree::Config.run_order_validations_on_order_updater set to false is ' \
            'deprecated and will not be possibile in Solidus 3.0. Please switch this ' \
            'value to true and check that everything works as expected.',
            caller
          )
        end

        if Spree::Config.use_legacy_address_state_validator != false
          Spree::Deprecation.warn(<<~DEPRECATION.squish, caller)
            Spree::Config.use_legacy_address_state_validator set to true has been
            deprecated and will be removed in Solidus 3.0. The Spree::Address state
            validation has been extracted into a configurable external class.
            Switch Spree::Config.use_legacy_address_state_validator to false to start
            using the external validation class.
          DEPRECATION
        end
      end

      # Load in mailer previews for apps to use in development.
      # We need to make sure we call `Preview.all` before requiring our
      # previews, otherwise any previews the app attempts to add need to be
      # manually required.
      if Rails.env.development?
        initializer "spree.mailer_previews" do
          ActionMailer::Preview.all
          Dir[root.join("lib/spree/mailer_previews/**/*_preview.rb")].each do |file|
            require_dependency file
          end
        end
      end
    end
  end
end
