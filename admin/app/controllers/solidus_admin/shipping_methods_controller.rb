# frozen_string_literal: true

module SolidusAdmin
  class ShippingMethodsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::ShippingMethod

    def resources_collection = Spree::ShippingMethod.unscoped

    def permitted_resource_params
      params.require(:shipping_method).permit(
        :name,
        :admin_name,
        :code,
        :carrier,
        :service_level,
        :tracking_url,
        :available_to_all,
        :available_to_users,
        :calculator_type,
        :tax_category_id,
        store_ids: [],
        stock_location_ids: [],
        zone_ids: [],
        shipping_category_ids: [],
        calculator_attributes: [
          :id,
          :preferred_amount,
          :preferred_currency,
          :preferred_flat_percent,
          :preferred_first_item,
          :preferred_additional_item,
          :preferred_max_items,
          :preferred_minimal_amount,
          :preferred_normal_amount,
          :preferred_discount_amount
        ]
      )
    end
  end
end
