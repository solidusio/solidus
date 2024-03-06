# frozen_string_literal: true

module Spree
  module Core
    class PromotionConfiguration < Spree::Preferences::Configuration
      include Core::EnvironmentExtension

      # @!attribute [rw] promotions_per_page
      #   @return [Integer] Promotions to show per-page in the admin (default: +15+)
      preference :promotions_per_page, :integer, default: 15

      # promotion_chooser_class allows extensions to provide their own PromotionChooser
      class_name_attribute :promotion_chooser_class, default: 'Spree::PromotionChooser'

      # promotion_adjuster_class allows extensions to provide their own Promotion Adjuster
      class_name_attribute :promotion_adjuster_class, default: 'Spree::Promotion::OrderAdjustmentsRecalculator'

      # promotion_finder_class allows extensions to provide their own Promotion Finder
      class_name_attribute :promotion_finder_class, default: 'Spree::PromotionFinder'

      # Allows providing a different shipping promotion handler.
      # @!attribute [rw] shipping_promotion_handler_class
      # @see Spree::PromotionHandler::Shipping
      # @return [Class] an object that conforms to the API of
      #   the standard shipping promotion handler class
      #   Spree::PromotionHandler::Coupon.
      class_name_attribute :shipping_promotion_handler_class, default: 'Spree::PromotionHandler::Shipping'

      # Allows providing your own Mailer for promotion code batch mailer.
      #
      # @!attribute [rw] promotion_code_batch_mailer_class
      # @return [ActionMailer::Base] an object that responds to "promotion_code_batch_finished",
      #   and "promotion_code_batch_errored"
      #   (e.g. an ActionMailer with a "promotion_code_batch_finished" method) with the same
      #   signature as Spree::PromotionCodeBatchMailer.promotion_code_batch_finished.
      class_name_attribute :promotion_code_batch_mailer_class, default: 'Spree::PromotionCodeBatchMailer'

      # Allows providing a different coupon code handler.
      # @!attribute [rw] coupon_code_handler_class
      # @see Spree::PromotionHandler::Coupon
      # @return [Class] an object that conforms to the API of
      #   the standard coupon code handler class
      #   Spree::PromotionHandler::Coupon.
      class_name_attribute :coupon_code_handler_class, default: 'Spree::PromotionHandler::Coupon'

      add_class_set :rules, default: %w[
        Spree::Promotion::Rules::ItemTotal
        Spree::Promotion::Rules::Product
        Spree::Promotion::Rules::User
        Spree::Promotion::Rules::FirstOrder
        Spree::Promotion::Rules::UserLoggedIn
        Spree::Promotion::Rules::OneUsePerUser
        Spree::Promotion::Rules::Taxon
        Spree::Promotion::Rules::MinimumQuantity
        Spree::Promotion::Rules::NthOrder
        Spree::Promotion::Rules::OptionValue
        Spree::Promotion::Rules::FirstRepeatPurchaseSince
        Spree::Promotion::Rules::UserRole
        Spree::Promotion::Rules::Store
      ]

      add_class_set :actions, default: %w[
        Spree::Promotion::Actions::CreateAdjustment
        Spree::Promotion::Actions::CreateItemAdjustments
        Spree::Promotion::Actions::CreateQuantityAdjustments
        Spree::Promotion::Actions::FreeShipping
      ]

      add_class_set :shipping_actions, default: %w[
        Spree::Promotion::Actions::FreeShipping
      ]

      add_nested_class_set :calculators, default: {
        "Spree::Promotion::Actions::CreateAdjustment" => %w[
          Spree::Calculator::FlatPercentItemTotal
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::TieredPercent
          Spree::Calculator::TieredFlatRate
        ],
        "Spree::Promotion::Actions::CreateItemAdjustments" => %w[
          Spree::Calculator::DistributedAmount
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::TieredPercent
        ],
        "Spree::Promotion::Actions::CreateQuantityAdjustments" => %w[
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::FlatRate
        ]
      }
    end
  end
end
