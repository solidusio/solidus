module Spree
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Spree
      engine_name 'spree'

      rake_tasks do
        load File.join(root, "lib", "tasks", "exchanges.rake")
      end

      initializer "spree.environment", :before => :load_config_initializers do |app|
        app.config.spree = Solidus::Core::Environment.new
        Solidus::Config = app.config.spree.preferences #legacy access
      end

      initializer "spree.default_permissions" do |app|
        Solidus::RoleConfiguration.configure do |config|
          config.assign_permissions :default, [Solidus::PermissionSets::DefaultCustomer]
          config.assign_permissions :admin, [Solidus::PermissionSets::SuperUser]
        end
      end

      initializer "spree.register.calculators" do |app|
        app.config.spree.calculators.shipping_methods = [
            Solidus::Calculator::Shipping::FlatPercentItemTotal,
            Solidus::Calculator::Shipping::FlatRate,
            Solidus::Calculator::Shipping::FlexiRate,
            Solidus::Calculator::Shipping::PerItem,
            Solidus::Calculator::Shipping::PriceSack]

         app.config.spree.calculators.tax_rates = [
            Solidus::Calculator::DefaultTax]
      end

      initializer "spree.register.stock_splitters" do |app|
        app.config.spree.stock_splitters = [
          Solidus::Stock::Splitter::ShippingCategory,
          Solidus::Stock::Splitter::Backordered
        ]
      end

      initializer "spree.register.payment_methods" do |app|
        app.config.spree.payment_methods = [
            Solidus::Gateway::Bogus,
            Solidus::Gateway::BogusSimple,
            Solidus::PaymentMethod::StoreCredit,
            Solidus::PaymentMethod::Check ]
      end

      # We need to define promotions rules here so extensions and existing apps
      # can add their custom classes on their initializer files
      initializer 'spree.promo.environment' do |app|
        app.config.spree.add_class('promotions')
        app.config.spree.promotions = Solidus::Promo::Environment.new
        app.config.spree.promotions.rules = []
      end

      initializer 'spree.promo.register.promotion.calculators' do |app|
        app.config.spree.calculators.add_class('promotion_actions_create_adjustments')
        app.config.spree.calculators.promotion_actions_create_adjustments = [
          Solidus::Calculator::FlatPercentItemTotal,
          Solidus::Calculator::FlatRate,
          Solidus::Calculator::FlexiRate,
          Solidus::Calculator::TieredPercent,
          Solidus::Calculator::TieredFlatRate
        ]

        app.config.spree.calculators.add_class('promotion_actions_create_item_adjustments')
        app.config.spree.calculators.promotion_actions_create_item_adjustments = [
          Solidus::Calculator::PercentOnLineItem,
          Solidus::Calculator::FlatRate,
          Solidus::Calculator::FlexiRate
        ]

        app.config.spree.calculators.add_class('promotion_actions_create_quantity_adjustments')
        app.config.spree.calculators.promotion_actions_create_item_adjustments = [
          Solidus::Calculator::PercentOnLineItem,
          Solidus::Calculator::FlatRate
        ]
      end

      # Promotion rules need to be evaluated on after initialize otherwise
      # Solidus.user_class would be nil and users might experience errors related
      # to malformed model associations (Solidus.user_class is only defined on
      # the app initializer)
      config.after_initialize do
        Rails.application.config.spree.promotions.rules.concat [
          Solidus::Promotion::Rules::ItemTotal,
          Solidus::Promotion::Rules::Product,
          Solidus::Promotion::Rules::User,
          Solidus::Promotion::Rules::FirstOrder,
          Solidus::Promotion::Rules::UserLoggedIn,
          Solidus::Promotion::Rules::OneUsePerUser,
          Solidus::Promotion::Rules::Taxon,
          Solidus::Promotion::Rules::NthOrder,
          Solidus::Promotion::Rules::OptionValue,
          Solidus::Promotion::Rules::FirstRepeatPurchaseSince,
        ]
      end

      initializer 'spree.promo.register.promotions.actions' do |app|
        app.config.spree.promotions.actions = [
          Promotion::Actions::CreateAdjustment,
          Promotion::Actions::CreateItemAdjustments,
          Promotion::Actions::CreateQuantityAdjustments,
          Promotion::Actions::FreeShipping]
      end

      # filter sensitive information during logging
      initializer "spree.params.filter" do |app|
        app.config.filter_parameters += [
          :password,
          :password_confirmation,
          :number,
          :verification_value]
      end

      initializer "spree.core.checking_migrations" do |app|
        Migrations.new(config, engine_name).check
      end
    end
  end
end

require 'solidus/core/routes'
