# frozen_string_literal: true

module Spree
  module Admin
    class ProductPropertiesController < ResourceController
      belongs_to 'spree/product', find_by: :slug, includes: { product_properties: :property }
      before_action :find_properties
      before_action :setup_property, only: :index, if: -> { can?(:create, model_class) }
      before_action :setup_variant_property_rules, only: :index

      private

      def find_properties
        @properties = Spree::Property.pluck(:name)
      end

      def setup_property
        @product.product_properties.build
      end

      def setup_variant_property_rules
        @option_types = @product.variant_option_values_by_option_type
        @option_value_ids = (params[:ovi] || []).reject(&:blank?).map(&:to_i)
        @variant_property_rule = @product.find_variant_property_rule(@option_value_ids) || @product.variant_property_rules.build
        @variant_property_rule.values.build if can?(:create, Spree::VariantPropertyRuleValue)
      end
    end
  end
end
