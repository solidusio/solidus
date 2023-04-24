# frozen_string_literal: true

module Spree
  module Api
    module ApiHelpers
      ATTRIBUTES = [
        :product_attributes,
        :product_property_attributes,
        :variant_attributes,
        :image_attributes,
        :option_value_attributes,
        :order_attributes,
        :line_item_attributes,
        :option_type_attributes,
        :payment_attributes,
        :payment_method_attributes,
        :shipment_attributes,
        :taxonomy_attributes,
        :taxon_attributes,
        :address_attributes,
        :country_attributes,
        :state_attributes,
        :adjustment_attributes,
        :inventory_unit_attributes,
        :customer_return_attributes,
        :return_authorization_attributes,
        :creditcard_attributes,
        :payment_source_attributes,
        :user_attributes,
        :property_attributes,
        :stock_location_attributes,
        :stock_movement_attributes,
        :stock_item_attributes,
        :promotion_attributes,
        :store_attributes,
        :store_credit_history_attributes,
        :variant_property_attributes
      ]

      ATTRIBUTES.each do |attribute|
        define_method attribute do
          Spree::Api::Config.send(attribute)
        end
      end

      def required_fields_for(model)
        required_fields = model._validators.select do |_field, validations|
          validations.any? { |validation| validation.is_a?(ActiveModel::Validations::PresenceValidator) }
        end.map(&:first) # get fields that are invalid
        # Permalinks presence is validated, but are really automatically generated
        # Therefore we shouldn't tell API clients that they MUST send one through
        required_fields.map!(&:to_s).delete("permalink")
        # Do not require slugs, either
        required_fields.delete("slug")
        required_fields
      end

      def variant_attributes
        preference_attributes = Spree::Api::Config.variant_attributes
        if @current_user_roles&.include?("admin")
          preference_attributes + [:cost_price]
        else
          preference_attributes
        end
      end

      def total_on_hand_for(object)
        object.total_on_hand.finite? ? object.total_on_hand : nil
      end
    end
  end
end
