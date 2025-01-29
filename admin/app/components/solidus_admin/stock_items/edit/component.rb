# frozen_string_literal: true

class SolidusAdmin::StockItems::Edit::Component < SolidusAdmin::Resources::Edit::Component
  def title
    [
      "#{Spree::StockLocation.model_name.human}: #{@stock_item.stock_location.name}",
    ].join(' / ')
  end
end
