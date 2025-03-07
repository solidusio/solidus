# frozen_string_literal: true

class SolidusAdmin::StockLocations::New::Component < SolidusAdmin::Resources::New::Component
  include SolidusAdmin::Layout::PageHelpers

  def initialize(*args)
    super(*args)
    ensure_country
  end

  private

  def ensure_country
    @stock_location.country.blank? && (@stock_location.country = Spree::Country.default)
  end
end
