# frozen_string_literal: true

class SolidusAdmin::StockItems::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(stock_item:, page:)
    @stock_item = stock_item
    @page = page
  end

  def title
    [
      "#{Spree::StockLocation.model_name.human}: #{@stock_item.stock_location.name}",
    ].join(' / ')
  end

  def form_id
    "#{stimulus_id}-#{dom_id(@stock_item)}"
  end

  def close_path
    solidus_admin.stock_items_path(**search_filter_params)
  end
end
