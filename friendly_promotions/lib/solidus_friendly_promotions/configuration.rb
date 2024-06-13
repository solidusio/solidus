# frozen_string_literal: true

require "spree/core/environment_extension"

module SolidusFriendlyPromotions
  class Configuration < Spree::Preferences::Configuration
    attr_accessor :sync_order_promotions
    attr_accessor :recalculate_complete_orders
    attr_accessor :promotion_calculators

    def initialize
      @sync_order_promotions = true
      @recalculate_complete_orders = true
      @promotion_calculators = NestedClassSet.new
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

    add_class_set :line_item_discount_calculators
    add_class_set :shipment_discount_calculators

    add_class_set :order_conditions
    add_class_set :line_item_conditions
    add_class_set :shipment_conditions

    add_class_set :actions

    class_name_attribute :discount_chooser_class, default: "SolidusFriendlyPromotions::DiscountChooser"
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
