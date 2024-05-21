# frozen_string_literal: true

module Spree
  module Core
    class NullPromotionConfiguration < Spree::Preferences::Configuration
      # order_adjuster_class allows extensions to provide their own Order Adjuster
      class_name_attribute :order_adjuster_class, default: 'Spree::NullPromotionAdjuster'

      # Allows providing a different coupon code handler.
      # @!attribute [rw] coupon_code_handler_class
      # @see Spree::NullPromotionHandler
      # @return [Class] an object that conforms to the API of
      #   the standard coupon code handler class
      #   Spree::NullPromotionHandler.
      class_name_attribute :coupon_code_handler_class, default: 'Spree::NullPromotionHandler'

      # Allows providing a different promotion finder.
      # @!attribute [rw] promotion_finder_class
      # @see Spree::NullPromotionFinder
      # @return [Class] an object that conforms to the API of
      #   the standard promotion finder class
      #   Spree::NullPromotionFinder.
      class_name_attribute :promotion_finder_class, default: 'Spree::NullPromotionFinder'

      # Allows providing a different promotion shipping promotion handler.
      # @!attribute [rw] shipping_promotion_handler_class
      # @see Spree::NullPromotionHandler
      # @return [Class] an object that conforms to the API of
      #   the standard promotion finder class
      #   Spree::NullPromotionHandler.
      class_name_attribute :shipping_promotion_handler_class, default: 'Spree::NullPromotionHandler'

      # Allows providing a different promotion advertiser.
      # @!attribute [rw] advertiser_class
      # @see Spree::NullPromotionAdvertiser
      # @return [Class] an object that conforms to the API of
      #   the standard promotion advertiser class
      #   Spree::NullPromotionAdvertiser.
      class_name_attribute :advertiser_class, default: 'Spree::NullPromotionAdvertiser'

      # !@attribute [rw] promotion_api_attributes
      #   @return [Array<Symbol>] Attributes to be returned by the API for a promotion
      preference :promotion_api_attributes, :array, default: []
    end
  end
end
