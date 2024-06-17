# frozen_string_literal: true

require "spree/core/environment_extension"

module SolidusFriendlyPromotions
  class Configuration < Spree::Preferences::Configuration
    attr_accessor :sync_order_promotions
    attr_accessor :recalculate_complete_orders

    def initialize
      @sync_order_promotions = true
      @recalculate_complete_orders = true
    end

    include Spree::Core::EnvironmentExtension

    class_name_attribute :order_adjuster_class, default: "SolidusFriendlyPromotions::FriendlyPromotionAdjuster"

    class_name_attribute :coupon_code_handler_class, default: "SolidusFriendlyPromotions::PromotionHandler::Coupon"

    class_name_attribute :promotion_finder_class, default: "SolidusFriendlyPromotions::PromotionFinder"

    # Allows providing a different promotion advertiser.
    # @!attribute [rw] advertiser_class
    # @see Spree::NullPromotionAdvertiser
    # @return [Class] an object that conforms to the API of
    #   the standard promotion advertiser class
    #   Spree::NullPromotionAdvertiser.
    class_name_attribute :advertiser_class, default: "SolidusFriendlyPromotions::PromotionAdvertiser"

    # In case solidus_legacy_promotions is loaded, we need to define this.
    class_name_attribute :shipping_promotion_handler_class, default: "Spree::NullPromotionHandler"

    add_class_set :order_conditions, default: [
      "SolidusFriendlyPromotions::Conditions::FirstOrder",
      "SolidusFriendlyPromotions::Conditions::FirstRepeatPurchaseSince",
      "SolidusFriendlyPromotions::Conditions::ItemTotal",
      "SolidusFriendlyPromotions::Conditions::DiscountedItemTotal",
      "SolidusFriendlyPromotions::Conditions::MinimumQuantity",
      "SolidusFriendlyPromotions::Conditions::NthOrder",
      "SolidusFriendlyPromotions::Conditions::OneUsePerUser",
      "SolidusFriendlyPromotions::Conditions::OptionValue",
      "SolidusFriendlyPromotions::Conditions::Product",
      "SolidusFriendlyPromotions::Conditions::Store",
      "SolidusFriendlyPromotions::Conditions::Taxon",
      "SolidusFriendlyPromotions::Conditions::UserLoggedIn",
      "SolidusFriendlyPromotions::Conditions::UserRole",
      "SolidusFriendlyPromotions::Conditions::User"
    ]

    add_class_set :line_item_conditions, default: [
      "SolidusFriendlyPromotions::Conditions::LineItemOptionValue",
      "SolidusFriendlyPromotions::Conditions::LineItemProduct",
      "SolidusFriendlyPromotions::Conditions::LineItemTaxon"
    ]
    add_class_set :shipment_conditions, default: [
      "SolidusFriendlyPromotions::Conditions::ShippingMethod"
    ]

    add_class_set :actions, default: [
      "SolidusFriendlyPromotions::Benefits::AdjustLineItem",
      "SolidusFriendlyPromotions::Benefits::AdjustLineItemQuantityGroups",
      "SolidusFriendlyPromotions::Benefits::AdjustShipment",
      "SolidusFriendlyPromotions::Benefits::CreateDiscountedItem"
    ]

    add_nested_class_set :promotion_calculators, default: {
      "SolidusFriendlyPromotions::Benefits::AdjustShipment" => [
        "SolidusFriendlyPromotions::Calculators::FlatRate",
        "SolidusFriendlyPromotions::Calculators::FlexiRate",
        "SolidusFriendlyPromotions::Calculators::Percent",
        "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
        "SolidusFriendlyPromotions::Calculators::TieredPercent",
        "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ],
      "SolidusFriendlyPromotions::Benefits::AdjustLineItem" => [
        "SolidusFriendlyPromotions::Calculators::DistributedAmount",
        "SolidusFriendlyPromotions::Calculators::FlatRate",
        "SolidusFriendlyPromotions::Calculators::FlexiRate",
        "SolidusFriendlyPromotions::Calculators::Percent",
        "SolidusFriendlyPromotions::Calculators::TieredFlatRate",
        "SolidusFriendlyPromotions::Calculators::TieredPercent",
        "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ],
      "SolidusFriendlyPromotions::Benefits::AdjustLineItemQuantityGroups" => [
        "SolidusFriendlyPromotions::Calculators::FlatRate",
        "SolidusFriendlyPromotions::Calculators::Percent",
        "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ],
      "SolidusFriendlyPromotions::Benefits::CreateDiscountedItem" => [
        "SolidusFriendlyPromotions::Calculators::FlatRate",
        "SolidusFriendlyPromotions::Calculators::Percent",
        "SolidusFriendlyPromotions::Calculators::TieredPercentOnEligibleItemQuantity"
      ]
    }

    class_name_attribute :discount_chooser_class, default: "SolidusFriendlyPromotions::FriendlyPromotionAdjuster::ChooseDiscounts"
    class_name_attribute :promotion_code_batch_mailer_class,
      default: "SolidusFriendlyPromotions::PromotionCodeBatchMailer"

    # @!attribute [rw] promotions_per_page
    #   @return [Integer] Promotions to show per-page in the admin (default: +25+)
    preference :promotions_per_page, :integer, default: 25

    preference :lanes, :hash, default: {
      pre: 0,
      default: 1,
      post: 2
    }

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
