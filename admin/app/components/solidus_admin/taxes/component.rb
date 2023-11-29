# frozen_string_literal: true

class SolidusAdmin::Taxes::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  renders_one :actions

  def initialize(model_class:)
    @model_class = model_class
  end

  def tabs
    [
      {
        text: Spree::TaxCategory.model_name.human.pluralize,
        href: solidus_admin.tax_categories_path,
        "aria-current": @model_class == Spree::TaxCategory,
      },
      {
        text: Spree::TaxRate.model_name.human.pluralize,
        href: solidus_admin.tax_rates_path,
        "aria-current": @model_class == Spree::TaxRate,
      },
    ]
  end
end
