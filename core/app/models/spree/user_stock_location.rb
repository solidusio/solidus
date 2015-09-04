module Spree
  class UserStockLocation < Spree::Base
    belongs_to :user, class_name: Spree::UserClassHandle.new, inverse_of: :user_stock_locations
    belongs_to :stock_location, class_name: "Spree::StockLocation", inverse_of: :user_stock_locations
  end
end
