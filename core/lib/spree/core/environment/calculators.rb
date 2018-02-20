# frozen_string_literal: true

module Spree
  module Core
    class Environment
      class Calculators
        include EnvironmentExtension

        add_class_set :shipping_methods
        add_class_set :tax_rates

        add_class_set :promotion_actions_create_adjustments
        add_class_set :promotion_actions_create_item_adjustments
        add_class_set :promotion_actions_create_quantity_adjustments
      end
    end
  end
end
