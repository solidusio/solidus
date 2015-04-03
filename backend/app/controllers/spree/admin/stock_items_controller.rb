module Spree
  module Admin
    class StockItemsController < ResourceController
      update.before :determine_backorderable

      private

        def location_after_destroy
          :back
        end

        def location_after_save
          :back
        end

        def build_resource
          variant = Variant.accessible_by(current_ability, :read).find(params[:variant_id])
          stock_location = StockLocation.accessible_by(current_ability, :read).find(params[:stock_location_id])
          stock_location.stock_movements.build(stock_movement_params).tap do |stock_movement|
            stock_movement.originator = try_spree_current_user
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
    end
  end
end
