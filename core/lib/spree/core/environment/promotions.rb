# frozen_string_literal: true

module Spree
  module Core
    class Environment
      class Promotions
        class << self
          private

          def promotions_deprecation_message(method)
            "The `Rails.application.config.spree.promotions.#{method}` preference is deprecated and will be removed in Solidus 5.0. " \
            "Use `Spree::Config.promotions.#{method}` instead."
          end
        end

        delegate :rules, :rules=, to: :promotion_config
        deprecate rules: promotions_deprecation_message("rules"), deprecator: Spree.deprecator
        deprecate "rules=": promotions_deprecation_message("rules="), deprecator: Spree.deprecator

        delegate :actions, :actions=, to: :promotion_config
        deprecate actions: promotions_deprecation_message("actions"), deprecator: Spree.deprecator
        deprecate "actions=": promotions_deprecation_message("actions="), deprecator: Spree.deprecator

        delegate :shipping_actions, :shipping_actions=, to: :promotion_config
        deprecate shipping_actions: promotions_deprecation_message("shipping_actions"), deprecator: Spree.deprecator
        deprecate "shipping_actions=": promotions_deprecation_message("shipping_actions="), deprecator: Spree.deprecator

        private

        def promotion_config
          Spree::Config.promotions
        end
      end
    end
  end
end
