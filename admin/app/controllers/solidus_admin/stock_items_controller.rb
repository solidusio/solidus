# frozen_string_literal: true

module SolidusAdmin
  class StockItemsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search
    before_action :load_stock_items, only: [:index, :edit, :update]
    before_action :load_stock_item, only: [:edit, :update]

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

    def edit
      respond_to do |format|
        format.html { render component('stock_items/edit').new(stock_item: @stock_item, page: @page) }
      end
    end

    def update
      quantity_adjustment = params[:quantity_adjustment].to_i
      @stock_item.assign_attributes(stock_item_params)
      @stock_item.stock_movements.build(quantity: quantity_adjustment, originator: current_solidus_admin_user)

      if @stock_item.save
        binding.pry
        respond_to do |format|
          format.html { redirect_to solidus_admin.stock_items_path, status: :see_other }
          format.turbo_stream { render turbo_stream: '<turbo-stream action="refresh" />' }
        end
      else
        binding.pry
        respond_to do |format|
          format.html { render component('stock_items/edit').new(stock_item: @stock_item, page: @page), status: :unprocessable_entity }
        end
      end
    end

    private

    def load_stock_items
      @stock_items = apply_search_to(
        Spree::StockItem.reorder(nil),
        param: :q,
      )

      set_page_and_extract_portion_from(@stock_items, ordered_by: {
        variant_id: :desc,
        stock_location_id: :desc,
        id: :desc,
      })
    end

    def load_stock_item
      @stock_item = Spree::StockItem.find(params[:id])
    end

    def stock_item_params
      params.require(:stock_item).permit(:backorderable)
    end
  end
end
