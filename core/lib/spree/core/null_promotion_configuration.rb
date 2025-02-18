# frozen_string_literal: true

module Spree
  module Core
    class NullPromotionConfiguration < Spree::Preferences::Configuration
      include Spree::Core::EnvironmentExtension

      # order_adjuster_class allows extensions to provide their own Order Adjuster
      class_name_attribute :order_adjuster_class, default: "Spree::NullPromotionAdjuster"

      # Allows providing a different coupon code handler.
      # @!attribute [rw] coupon_code_handler_class
      # @see Spree::NullPromotionHandler
      # @return [Class] an object that conforms to the API of
      #   the standard coupon code handler class
      #   Spree::NullPromotionHandler.
      class_name_attribute :coupon_code_handler_class, default: "Spree::NullPromotionHandler"

      # Allows providing a different promotion finder.
      # @!attribute [rw] promotion_finder_class
      # @see Spree::NullPromotionFinder
      # @return [Class] an object that conforms to the API of
      #   the standard promotion finder class
      #   Spree::NullPromotionFinder.
      class_name_attribute :promotion_finder_class, default: "Spree::NullPromotionFinder"

      # Allows getting and setting `Spree::Config.promotion_code_batch_mailer_class`.
      # Both will issue a deprecation warning.
      class_name_attribute :promotion_code_batch_mailer_class, default: "Spree::DeprecatedConfigurableClass"
      deprecate :promotion_code_batch_mailer_class, :promotion_code_batch_mailer_class=, deprecator: Spree.deprecator

      # Allows getting and setting `Spree::Config.promotion_chooser_class`.
      # Both will issue a deprecation warning.
      class_name_attribute :promotion_chooser_class, default: "Spree::DeprecatedConfigurableClass"
      deprecate :promotion_chooser_class, :promotion_chooser_class=, deprecator: Spree.deprecator

      # Allows getting and setting rules. Deprecated.
      # @!attribute [rw] rules
      # @return [Array] a set of rules
      add_class_set :rules
      deprecate :rules, :rules=, deprecator: Spree.deprecator

      # Allows getting and setting actions. Deprecated.
      # @!attribute [rw] actions
      # @return [Array] a set of actions
      add_class_set :actions
      deprecate :actions, :actions=, deprecator: Spree.deprecator

      # Allows getting and setting shipping actions. Deprecated.
      # @!attribute [rw] shipping_actions
      # @return [Array] a set of shipping_actions
      add_class_set :shipping_actions
      deprecate :shipping_actions, :shipping_actions=, deprecator: Spree.deprecator

      # Allows getting an setting calculators for actions. Deprecated.
      # @!attribute [rw] calculators
      # @return [Spree::Core::NestedClassSet] a set of calculators
      add_nested_class_set :calculators
      deprecate :calculators, :calculators=, deprecator: Spree.deprecator

      # Allows providing a different promotion shipping promotion handler.
      # @!attribute [rw] shipping_promotion_handler_class
      # @see Spree::NullPromotionHandler
      # @return [Class] an object that conforms to the API of
      #   the standard promotion finder class
      #   Spree::NullPromotionHandler.
      class_name_attribute :shipping_promotion_handler_class, default: "Spree::NullPromotionHandler"
      deprecate :shipping_promotion_handler_class, deprecator: Spree.deprecator
      deprecate :shipping_promotion_handler_class=, deprecator: Spree.deprecator

      # Allows providing a different promotion advertiser.
      # @!attribute [rw] advertiser_class
      # @see Spree::NullPromotionAdvertiser
      # @return [Class] an object that conforms to the API of
      #   the standard promotion advertiser class
      #   Spree::NullPromotionAdvertiser.
      class_name_attribute :advertiser_class, default: "Spree::NullPromotionAdvertiser"

      # !@attribute [rw] promotion_api_attributes
      #   @return [Array<Symbol>] Attributes to be returned by the API for a promotion
      preference :promotion_api_attributes, :array, default: []
    end
  end
end
