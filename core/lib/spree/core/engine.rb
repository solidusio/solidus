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

      initializer "spree.zeitwerk_ignores" do
        old_helpers = Engine.root.join("lib", "spree", "core", "controller_helpers", "*", "*.rb")
        Rails.application.autoloaders.main.ignore(old_helpers)
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
        app.reloader.to_prepare do
          Spree::Bus.clear

          %i[
            carton_shipped
            order_canceled
            order_emptied
            order_finalized
            order_recalculated
            order_short_shipped
            reimbursement_reimbursed
            reimbursement_errored
          ].each { |event_name| Spree::Bus.register(event_name) }

          Spree::OrderMailerSubscriber.new.subscribe_to(Spree::Bus)
          Spree::ReimbursementMailerSubscriber.new.subscribe_to(Spree::Bus)
        end
      end

      # Load in mailer previews for apps to use in development.
      initializer "spree.core.action_mailer.set_preview_path", after: "action_mailer.set_autoload_paths" do
        solidus_preview_path = Spree::Core::Engine.root.join("lib/spree/mailer_previews")

        if ActionMailer::Base.respond_to? :preview_paths # Rails 7.1+
          ActionMailer::Base.preview_paths << solidus_preview_path.to_s
        else
          ActionMailer::Base.preview_path = "{#{ActionMailer::Base.preview_path},#{solidus_preview_path}}"
        end
      end

      initializer "spree.deprecator" do |app|
        if app.respond_to?(:deprecators)
          app.deprecators[:spree] = Spree.deprecator
        end
      end

      config.after_initialize do
        Spree::Config.check_load_defaults_called('Spree::Config')
        Spree::Config.static_model_preferences.validate!
      end

      config.after_initialize do
        if defined?(Spree::Auth::Engine) &&
            Gem::Version.new(Spree::Auth::VERSION) < Gem::Version.new('2.5.4') &&
            defined?(Spree::UsersController)
          Spree::UsersController.protect_from_forgery with: :exception
        end
      end
    end
  end
end
