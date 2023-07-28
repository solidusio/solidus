# frozen_string_literal: true

module Spree
  module Admin
    class StockItemsController < ResourceController
      class_attribute :variant_display_attributes
      self.variant_display_attributes = [
        { translation_key: :sku, attr_name: :sku },
        { translation_key: :name, attr_name: :name }
      ]

      update.before :determine_backorderable
      before_action :load_product, :load_stock_management_data, only: :index

      private

      def build_resource
        variant = Spree::Variant.accessible_by(current_ability, :show).find(params[:variant_id])
        stock_location = Spree::StockLocation.accessible_by(current_ability, :show).find(params[:stock_location_id])
        stock_location.stock_movements.build(stock_movement_params).tap do |stock_movement|
          stock_movement.originator = spree_current_user
          stock_movement.stock_item = stock_location.set_up_stock_item(variant)
        end
      end

      def permitted_resource_params
        {}
      end

      def stock_movement_params
        params.require(:stock_movement).permit(permitted_stock_movement_attributes)
      end

      def determine_backorderable
        @stock_item.backorderable = params[:stock_item].present? && params[:stock_item][:backorderable].present?
      end

      def load_product
        @product = Spree::Product.accessible_by(current_ability, :show).friendly.find(params[:product_slug]) if params[:product_slug]
      end

      def load_stock_management_data
        @stock_locations = Spree::StockLocation.accessible_by(current_ability, :read)
        @stock_item_stock_locations = Spree::DeprecatedInstanceVariableProxy.new(
          view_context,
          :@stock_locations,
          :stock_item_stock_locations,
          Spree.deprecator,
          "Please, do not use @stock_item_stock_locations anymore in the views, use @stock_locations",
        )
        @variant_display_attributes = self.class.variant_display_attributes
        @variants = Spree::Config.variant_search_class.new(params[:variant_search_term], scope: variant_scope).results.
            order(id: :desc).page(params[:page]).per(params[:per_page] || Spree::Config[:orders_per_page])
      end

      def variant_scope
        scope = Spree::Variant
          .accessible_by(current_ability)
          .distinct.order(:sku)
          .includes(
            :images,
            stock_items: :stock_location,
            product: :variant_images,
            option_values: :option_type
          )

        scope = scope.where(product: @product, is_master: !@product.has_variants?) if @product
        scope = scope.by_stock_location(params[:stock_location_id]) if params[:stock_location_id].present?

        scope
      end

      def collection
        []
      end
    end
  end
end
