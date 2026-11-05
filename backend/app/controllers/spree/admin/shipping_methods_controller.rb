# frozen_string_literal: true

module Spree
  module Admin
    class ShippingMethodsController < ResourceController
      before_action :load_data, except: :index
      before_action :set_shipping_category, only: [:create, :update]
      before_action :set_zones, only: [:create, :update]

      def destroy
        @object.discard

        flash[:success] = flash_message_for(@object, :successfully_removed)

        respond_with(@object) do |format|
          format.html { redirect_to collection_url }
          format.js { render_js_for_destroy }
        end
      end

      private

      def permitted_resource_params
        params.require(:shipping_method).permit(
          :name, :admin_name, :code, :carrier, :service_level, :tracking_url,
          :available_to_all, :available_to_users, :tax_category_id, :calculator_type,
          store_ids: [],
          stock_location_ids: [],
          calculator_attributes: [:id, *calculator_attributes]
        )
      end

      def calculator_attributes
        @calculators.flat_map do |calculator_class|
          calculator_class.permitted_preference_attributes
        end
      end

      def set_shipping_category
        return true if params["shipping_method"][:shipping_categories] == ""
        @shipping_method.shipping_categories = Spree::ShippingCategory.where(id: params["shipping_method"][:shipping_categories])
        @shipping_method.save
        params[:shipping_method].delete(:shipping_categories)
      end

      def set_zones
        return true if params["shipping_method"][:zones] == ""
        @shipping_method.zones = Spree::Zone.where(id: params["shipping_method"][:zones])
        @shipping_method.save
        params[:shipping_method].delete(:zones)
      end

      def location_after_save
        edit_admin_shipping_method_path(@shipping_method)
      end

      def load_data
        @available_zones = Spree::Zone.order(:name)
        @tax_categories = Spree::TaxCategory.order(:name)
        @calculators = Rails.application.config.spree.calculators.shipping_methods
      end
    end
  end
end
