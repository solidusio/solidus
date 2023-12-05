# frozen_string_literal: true

module SolidusAdmin
  class StockItemsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:all, default: true) { _1 }
    search_scope(:back_orderable) { _1.where(backorderable: true) }
    search_scope(:out_of_stock) { _1.where('count_on_hand <= 0') }
    search_scope(:low_stock) { _1.where('count_on_hand > 0 AND count_on_hand < ?', SolidusAdmin::Config[:low_stock_value]) }
    search_scope(:in_stock) { _1.where('count_on_hand > 0') }

    def index
      stock_items = apply_search_to(
        Spree::StockItem.order(created_at: :desc, id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(stock_items)

      respond_to do |format|
        format.html { render component('stock_items/index').new(page: @page) }
      end
    end
  end
end
