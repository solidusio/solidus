# frozen_string_literal: true

class SolidusAdmin::Shipping::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  renders_one :actions

  def initialize(current_class:)
    @current_class = current_class
  end

  def tabs
    {
      Spree::ShippingMethod => solidus_admin.shipping_methods_path,
      Spree::ShippingCategory => solidus_admin.shipping_categories_path,
      Spree::StockLocation => solidus_admin.stock_locations_path,
    }
  end
end
