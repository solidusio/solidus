module Spree
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Spree
      engine_name 'spree'

      rake_tasks do
        load File.join(root, "lib", "tasks", "exchanges.rake")
      end

      config.generators do |g|
        g.test_framework :rspec
      end

      initializer "spree.environment", before: :load_config_initializers do |app|
        app.config.spree = Spree::Core::Environment.new
        Spree::Config = app.config.spree.preferences # legacy access
      end

      initializer "spree.default_permissions", before: :load_config_initializers do |_app|
        Spree::RoleConfiguration.configure do |config|
          config.assign_permissions :default, [Spree::PermissionSets::DefaultCustomer]
          config.assign_permissions :admin, [Spree::PermissionSets::SuperUser]
        end
      end

      initializer "spree.register.calculators", before: :load_config_initializers do |app|
        app.config.spree.calculators.shipping_methods = %w[
          Spree::Calculator::Shipping::FlatPercentItemTotal
          Spree::Calculator::Shipping::FlatRate
          Spree::Calculator::Shipping::FlexiRate
          Spree::Calculator::Shipping::PerItem
          Spree::Calculator::Shipping::PriceSack
        ]

        app.config.spree.calculators.tax_rates = %w[
          Spree::Calculator::DefaultTax
        ]
      end

      initializer "spree.register.stock_splitters", before: :load_config_initializers do |app|
        app.config.spree.stock_splitters = %w[
          Spree::Stock::Splitter::ShippingCategory
          Spree::Stock::Splitter::Backordered
        ]
      end

      initializer "spree.register.payment_methods", before: :load_config_initializers do |app|
        app.config.spree.payment_methods = %w[
          Spree::Gateway::Bogus
          Spree::Gateway::BogusSimple
          Spree::PaymentMethod::StoreCredit
          Spree::PaymentMethod::Check
        ]
      end

      # We need to define promotions rules here so extensions and existing apps
      # can add their custom classes on their initializer files
      initializer 'spree.promo.environment', before: :load_config_initializers do |app|
        app.config.spree.promotions = Spree::Promo::Environment.new
        app.config.spree.promotions.rules = []
      end

      initializer 'spree.promo.register.promotion.calculators', before: :load_config_initializers do |app|
        app.config.spree.calculators.promotion_actions_create_adjustments = %w[
          Spree::Calculator::FlatPercentItemTotal
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::TieredPercent
          Spree::Calculator::TieredFlatRate
        ]

        app.config.spree.calculators.promotion_actions_create_item_adjustments = %w[
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::TieredPercent
        ]

        app.config.spree.calculators.promotion_actions_create_quantity_adjustments = %w[
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::FlatRate
        ]
      end

      initializer 'spree.promo.register.promotion.rules', before: :load_config_initializers do |app|
        app.config.spree.promotions.rules = %w[
          Spree::Promotion::Rules::ItemTotal
          Spree::Promotion::Rules::Product
          Spree::Promotion::Rules::User
          Spree::Promotion::Rules::FirstOrder
          Spree::Promotion::Rules::UserLoggedIn
          Spree::Promotion::Rules::OneUsePerUser
          Spree::Promotion::Rules::Taxon
          Spree::Promotion::Rules::NthOrder
          Spree::Promotion::Rules::OptionValue
          Spree::Promotion::Rules::FirstRepeatPurchaseSince
        ]
      end

      initializer 'spree.promo.register.promotions.actions', before: :load_config_initializers do |app|
        app.config.spree.promotions.actions = %w[
          Spree::Promotion::Actions::CreateAdjustment
          Spree::Promotion::Actions::CreateItemAdjustments
          Spree::Promotion::Actions::CreateQuantityAdjustments
          Spree::Promotion::Actions::FreeShipping
        ]
      end

      # filter sensitive information during logging
      initializer "spree.params.filter", before: :load_config_initializers do |app|
        app.config.filter_parameters += [
          :password,
          :password_confirmation,
          :number,
          :verification_value]
      end

      initializer "spree.core.checking_migrations", before: :load_config_initializers do |_app|
        Migrations.new(config, engine_name).check
      end
    end
  end
end

require 'spree/core/routes'
