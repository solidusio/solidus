# frozen_string_literal: true

class SolidusAdmin::Taxes::Component < SolidusAdmin::UI::Pages::Index::Component
  def title
    safe_join([
      tag.div(t(".title")),
      tag.div(t(".subtitle"), class: "font-normal text-sm text-gray-500")
    ])
  end

  def tabs
    [
      {
        text: Spree::TaxCategory.model_name.human.pluralize,
        href: solidus_admin.tax_categories_path,
        current: model_class == Spree::TaxCategory
      },
      {
        text: Spree::TaxRate.model_name.human.pluralize,
        href: solidus_admin.tax_rates_path,
        current: model_class == Spree::TaxRate
      }
    ]
  end
end
