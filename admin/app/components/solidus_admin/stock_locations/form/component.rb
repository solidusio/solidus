# frozen_string_literal: true

class SolidusAdmin::StockLocations::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(stock_location:, id:, url:)
    @stock_location = stock_location
    @id = id
    @url = url
  end
end
