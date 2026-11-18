# frozen_string_literal: true

class SolidusAdmin::Products::Show::Specifications::Form::Component < SolidusAdmin::BaseComponent
  def initialize(product:)
    @product = product
  end

  def form_id
    dom_id(@product, :product_properties)
  end

  def new_row_path
    solidus_admin.new_product_product_properties_path(@product)
  end
end
