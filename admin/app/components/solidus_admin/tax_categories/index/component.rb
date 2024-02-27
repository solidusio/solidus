# frozen_string_literal: true

class SolidusAdmin::TaxCategories::Index::Component < SolidusAdmin::Taxes::Component
  def row_url(tax_category)
    spree.edit_admin_tax_category_path(tax_category)
  end

  def model_class
    Spree::TaxCategory
  end

  def search_url
    solidus_admin.tax_categories_path
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_tax_category_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def search_key
    :name_or_description_cont
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.tax_categories_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      :name,
      :tax_code,
      :description,
      {
        header: :is_default,
        data: ->(tax_category) {
          if tax_category.is_default?
            component('ui/badge').yes
          else
            component('ui/badge').no
          end
        },
      },
    ]
  end
end
