# frozen_string_literal: true

class SolidusAdmin::Products::Form::Shipping::Component < SolidusAdmin::BaseComponent
  def initialize(form:)
    @form = form
  end

  private

  def shipping_category_options
    @shipping_category_options ||= [[t(".none"), nil]] + Spree::ShippingCategory.order(:name).pluck(:name, :id)
  end

  def tax_category_options
    @tax_category_options ||= [[t(".none"), nil]] + Spree::TaxCategory.order(:name).pluck(:name, :id)
  end
end
