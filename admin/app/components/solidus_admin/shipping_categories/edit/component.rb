# frozen_string_literal: true

class SolidusAdmin::ShippingCategories::Edit::Component < SolidusAdmin::ShippingCategories::Index::Component
  def initialize(page:, shipping_category:)
    @page = page
    @shipping_category = shipping_category
  end

  def form_id
    dom_id(@shipping_category, "#{stimulus_id}_edit_shipping_category_form")
  end

  def close_path
    solidus_admin.shipping_categories_path(**search_filter_params)
  end
end
