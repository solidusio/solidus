# frozen_string_literal: true

module Spree
  module Core
    class Environment
      class Calculators
        include EnvironmentExtension

        add_class_set :shipping_methods
        add_class_set :tax_rates

        def promotion_actions_create_adjustments
          promotion_config.calculators["Spree::Promotion::Actions::CreateAdjustment"]
        end
        deprecate :promotion_actions_create_adjustments, deprecator: Spree.deprecator

        def promotion_actions_create_adjustments=(value)
          promotion_config.calculators["Spree::Promotion::Actions::CreateAdjustment"] = value
        end
        deprecate :promotion_actions_create_adjustments=, deprecator: Spree.deprecator

        def promotion_actions_create_item_adjustments
          promotion_config.calculators["Spree::Promotion::Actions::CreateItemAdjustments"]
        end
        deprecate :promotion_actions_create_item_adjustments, deprecator: Spree.deprecator

        def promotion_actions_create_item_adjustments=(value)
          promotion_config.calculators["Spree::Promotion::Actions::CreateItemAdjustments"] = value
        end
        deprecate :promotion_actions_create_item_adjustments=, deprecator: Spree.deprecator

        def promotion_actions_create_quantity_adjustments
          promotion_config.calculators["Spree::Promotion::Actions::CreateQuantityAdjustments"]
        end
        deprecate :promotion_actions_create_quantity_adjustments, deprecator: Spree.deprecator

        def promotion_actions_create_quantity_adjustments=(value)
          promotion_config.calculators["Spree::Promotion::Actions::CreateQuantityAdjustments"] = value
        end
        deprecate :promotion_actions_create_quantity_adjustments=, deprecator: Spree.deprecator

        private

        def promotion_config
          Spree::Config.promotions
        end
      end
    end
  end
end
