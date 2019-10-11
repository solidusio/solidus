# frozen_string_literal: true

module Solidus
  class UserStockLocation < Solidus::Base
    belongs_to :user, class_name: Solidus::UserClassHandle.new, inverse_of: :user_stock_locations, optional: true
    belongs_to :stock_location, class_name: "Solidus::StockLocation", inverse_of: :user_stock_locations, optional: true
  end
end
