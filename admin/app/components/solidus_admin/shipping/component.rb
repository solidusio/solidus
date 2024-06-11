# frozen_string_literal: true

class SolidusAdmin::Shipping::Component < SolidusAdmin::UI::Pages::Index::Component
  def title
    page_header_title safe_join([
      tag.div(t(".title")),
      tag.div(t(".subtitle"), class: "font-normal text-sm text-gray-500"),
    ])
  end

  def tabs
    [
      {
        text: Spree::ShippingMethod.model_name.human.pluralize,
        href: solidus_admin.shipping_methods_path,
        current: model_class == Spree::ShippingMethod,
      },
      {
        text: Spree::ShippingCategory.model_name.human.pluralize,
        href: solidus_admin.shipping_categories_path,
        current: model_class == Spree::ShippingCategory,
      },
      {
        text: Spree::StockLocation.model_name.human.pluralize,
        href: solidus_admin.stock_locations_path,
        current: model_class == Spree::StockLocation,
      },
    ]
  end
end
