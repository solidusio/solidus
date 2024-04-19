# frozen_string_literal: true

class SolidusAdmin::ShippingCategories::New::Component < SolidusAdmin::ShippingCategories::Index::Component
  def initialize(page:, shipping_category:)
    @page = page
    @shipping_category = shipping_category
  end

  def form_id
    dom_id(@shipping_category, "#{stimulus_id}_new_shipping_category_form")
  end
end
