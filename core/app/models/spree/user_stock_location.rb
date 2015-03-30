module Spree
  class UserStockLocation < ActiveRecord::Base
    belongs_to :user, class_name: Spree.user_class.to_s, inverse_of: :user_stock_locations
    belongs_to :stock_location, class_name: "Spree::StockLocation", inverse_of: :user_stock_locations
  end
end
