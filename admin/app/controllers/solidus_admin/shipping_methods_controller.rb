# frozen_string_literal: true

module SolidusAdmin
  class ShippingMethodsController < SolidusAdmin::ResourcesController
    before_action :set_shipping_category, only: [:update]
    before_action :set_zones, only: [:update]

    def create
      @resource = resource_class.new(permitted_resource_params)
      set_shipping_category
      set_zones

      if @resource.save
        flash[:notice] = t('.success')
        redirect_to after_create_path, status: :see_other
      else
        page_component = new_component.new(@resource)
        render_resource_form_with_errors(page_component)
      end
    end

    def update
      if @resource.update(permitted_resource_params)
        flash[:notice] = t('.success')
        redirect_to after_update_path, status: :see_other
      else
        page_component = edit_component.new(@resource)
        render_resource_form_with_errors(page_component)
      end
    end

    private

    def resource_class = Spree::ShippingMethod

    def resources_collection = Spree::ShippingMethod.unscoped

    def set_shipping_category
      assign_association(:shipping_categories, Spree::ShippingCategory)
    end

    def set_zones
      assign_association(:zones, Spree::Zone)
    end

    def assign_association(association_name, model_class)
      return true if params["shipping_method"][association_name].blank?

      @resource.send("#{association_name}=", model_class.where(id: params["shipping_method"][association_name]))
      @resource.save
      params[:shipping_method].delete(association_name)
    end

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
