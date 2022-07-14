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

      if ActiveRecord.respond_to?(:yaml_column_permitted_classes) || ActiveRecord::Base.respond_to?(:yaml_column_permitted_classes)
        config.active_record.yaml_column_permitted_classes ||= []
        config.active_record.yaml_column_permitted_classes |=
          [Symbol, BigDecimal, ActiveSupport::HashWithIndifferentAccess]
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

      initializer "spree.core.checking_migrations", after: :load_config_initializers do |_app|
        Migrations.new(config, engine_name).check
      end

      # Setup pub/sub
      initializer 'spree.core.pub_sub' do |app|
        if Spree::Config.use_legacy_events
          app.reloader.to_prepare do
            Spree::Event.activate_autoloadable_subscribers
          end

          app.reloader.before_class_unload do
            Spree::Event.deactivate_all_subscribers
          end
        else
          app.reloader.to_prepare do
            Spree::Bus.clear

            %i[
              order_finalized
              order_recalculated
              reimbursement_reimbursed
              reimbursement_errored
            ].each { |event_name| Spree::Bus.register(event_name) }

            Spree::OrderMailerSubscriber.new.subscribe_to(Spree::Bus)
          end
        end
      end

      # Load in mailer previews for apps to use in development.
      initializer "spree.core.action_mailer.set_preview_path", after: "action_mailer.set_configs" do |app|
        original_preview_path = app.config.action_mailer.preview_path
        solidus_preview_path = Spree::Core::Engine.root.join 'lib/spree/mailer_previews'

        app.config.action_mailer.preview_path = "{#{original_preview_path},#{solidus_preview_path}}"
        ActionMailer::Base.preview_path = app.config.action_mailer.preview_path
      end

      config.after_initialize do
        Spree::Config.check_load_defaults_called('Spree::Config')
      end

      config.after_initialize do
        if defined?(Spree::Auth::Engine) &&
            Gem::Version.new(Spree::Auth::VERSION) < Gem::Version.new('2.5.4') &&
            defined?(Spree::UsersController)
          Spree::UsersController.protect_from_forgery with: :exception
        end
      end

      config.after_initialize do
        if Spree::Config.use_legacy_events && !ENV['CI']
          Spree::Deprecation.warn <<~MSG
            Your Solidus store is using the legacy event system. You're
            encouraged to switch to the new event bus. After you're done, you
            can remove the `use_legacy_events` setting from `spree.rb`.
          MSG
        end
      end
    end
  end
end
