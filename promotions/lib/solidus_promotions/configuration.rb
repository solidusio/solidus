# frozen_string_literal: true

require "spree/core/environment_extension"

module SolidusPromotions
  class Configuration < Spree::Preferences::Configuration
    include Spree::Core::EnvironmentExtension

    class_name_attribute :order_adjuster_class, default: "SolidusPromotions::OrderAdjuster"

    class_name_attribute :coupon_code_handler_class, default: "SolidusPromotions::PromotionHandler::Coupon"

    # The class used to normalize coupon codes before saving or lookup.
    # By default, this normalizes codes to lowercase for case-insensitive matching.
    # You can customize this by creating your own normalizer class or by overriding
    # the existing SolidusPromotions::CouponCodeNormalizer class using a decorator.
    # @!attribute [rw] coupon_code_normalizer_class
    #   @return [String] The class used to normalize coupon codes.
    #   Defaults to "SolidusPromotions::CouponCodeNormalizer".
    class_name_attribute :coupon_code_normalizer_class, default: "SolidusPromotions::CouponCodeNormalizer"

    class_name_attribute :promotion_finder_class, default: "SolidusPromotions::PromotionFinder"

    # Allows providing a different promotion advertiser.
    # @!attribute [rw] advertiser_class
    # @see Spree::NullPromotionAdvertiser
    # @return [Class] an object that conforms to the API of
    #   the standard promotion advertiser class
    #   Spree::NullPromotionAdvertiser.
    class_name_attribute :advertiser_class, default: "SolidusPromotions::PromotionAdvertiser"

    # In case solidus_legacy_promotions is loaded, we need to define this.
    class_name_attribute :shipping_promotion_handler_class, default: "Spree::NullPromotionHandler"

    add_class_set :order_conditions, default: [
      "SolidusPromotions::Conditions::FirstOrder",
      "SolidusPromotions::Conditions::FirstRepeatPurchaseSince",
      "SolidusPromotions::Conditions::ItemTotal",
      "SolidusPromotions::Conditions::DiscountedItemTotal",
      "SolidusPromotions::Conditions::MinimumQuantity",
      "SolidusPromotions::Conditions::NthOrder",
      "SolidusPromotions::Conditions::OneUsePerUser",
      "SolidusPromotions::Conditions::OptionValue",
      "SolidusPromotions::Conditions::OrderOptionValue",
      "SolidusPromotions::Conditions::OrderProduct",
      "SolidusPromotions::Conditions::Product",
      "SolidusPromotions::Conditions::Store",
      "SolidusPromotions::Conditions::Taxon",
      "SolidusPromotions::Conditions::OrderTaxon",
      "SolidusPromotions::Conditions::UserLoggedIn",
      "SolidusPromotions::Conditions::UserRole",
      "SolidusPromotions::Conditions::User"
    ]

    add_class_set :line_item_conditions, default: [
      "SolidusPromotions::Conditions::LineItemOptionValue",
      "SolidusPromotions::Conditions::LineItemProduct",
      "SolidusPromotions::Conditions::LineItemTaxon"
    ]
    add_class_set :shipment_conditions, default: [
      "SolidusPromotions::Conditions::ShippingMethod"
    ]

    add_class_set :benefits, default: [
      "SolidusPromotions::Benefits::AdjustLineItem",
      "SolidusPromotions::Benefits::AdjustLineItemQuantityGroups",
      "SolidusPromotions::Benefits::AdjustShipment",
      "SolidusPromotions::Benefits::CreateDiscountedItem"
    ]

    add_nested_class_set :promotion_calculators, default: {
      "SolidusPromotions::Benefits::AdjustShipment" => [
        "SolidusPromotions::Calculators::FlatRate",
        "SolidusPromotions::Calculators::Percent",
        "SolidusPromotions::Calculators::TieredFlatRate",
        "SolidusPromotions::Calculators::TieredPercent",
        "SolidusPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ],
      "SolidusPromotions::Benefits::AdjustLineItem" => [
        "SolidusPromotions::Calculators::DistributedAmount",
        "SolidusPromotions::Calculators::FlatRate",
        "SolidusPromotions::Calculators::FlexiRate",
        "SolidusPromotions::Calculators::Percent",
        "SolidusPromotions::Calculators::PercentWithCap",
        "SolidusPromotions::Calculators::TieredFlatRate",
        "SolidusPromotions::Calculators::TieredPercent",
        "SolidusPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ],
      "SolidusPromotions::Benefits::AdjustLineItemQuantityGroups" => [
        "SolidusPromotions::Calculators::FlatRate",
        "SolidusPromotions::Calculators::Percent",
        "SolidusPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ],
      "SolidusPromotions::Benefits::CreateDiscountedItem" => [
        "SolidusPromotions::Calculators::FlatRate",
        "SolidusPromotions::Calculators::Percent",
        "SolidusPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ]
    }

    class_name_attribute :discount_chooser_class, default: "SolidusPromotions::OrderAdjuster::ChooseDiscounts"
    class_name_attribute :promotion_code_batch_mailer_class,
      default: "SolidusPromotions::PromotionCodeBatchMailer"

    # @!attribute [rw] promotions_per_page
    #   @return [Integer] Promotions to show per-page in the admin (default: +25+)
    preference :promotions_per_page, :integer, default: 25

    preference :lanes, :hash, default: {
      pre: 0,
      default: 1,
      post: 2
    }

    preference :recalculate_complete_orders, :boolean, default: true

    preference :sync_order_promotions, :boolean, default: false

    preference :use_new_admin, :boolean, default: false
    def use_new_admin?
      SolidusSupport.admin_available? && preferred_use_new_admin
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration

    def configure
      yield configuration
    end
  end
end
