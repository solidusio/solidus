# frozen_string_literal: true

module SolidusAdmin
  class StockItemsController < SolidusAdmin::ResourcesController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:all, default: true) { _1 }
    search_scope(:back_orderable) { _1.where(backorderable: true) }
    search_scope(:out_of_stock) { _1.where('count_on_hand <= 0') }
    search_scope(:low_stock) { _1.where('count_on_hand > 0 AND count_on_hand < ?', SolidusAdmin::Config[:low_stock_value]) }
    search_scope(:in_stock) { _1.where('count_on_hand > 0') }

    def index
      respond_to do |format|
        format.html { render component('stock_items/index').new(page: @page) }
      end
    end

    def update
      quantity_adjustment = params[:quantity_adjustment].to_i
      @stock_item.assign_attributes(permitted_resource_params)
      @stock_item.stock_movements.build(quantity: quantity_adjustment, originator: current_solidus_admin_user)

      if @stock_item.save
        redirect_to after_update_path, status: :see_other
      else
        page_component = edit_component.new(@stock_item)
        render_resource_form_with_errors(page_component)
      end
    end

    private

    def resource_class = Spree::StockItem

    def resources_collection = Spree::StockItem.reorder(nil)

    def resources_sorting_options
      {
        variant_id: :desc,
        stock_location_id: :desc,
        id: :desc,
      }
    end

    def permitted_resource_params
      params.require(:stock_item).permit(:backorderable)
    end
  end
end
