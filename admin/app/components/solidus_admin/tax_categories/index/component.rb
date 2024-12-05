# frozen_string_literal: true

class SolidusAdmin::TaxCategories::Index::Component < SolidusAdmin::Taxes::Component
  def row_url(tax_category)
    edit_path(tax_category)
  end

  def edit_path(tax_category)
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
      href: solidus_admin.new_tax_category_path, data: { turbo_frame: :new_tax_category_modal },
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def turbo_frames
    %w[
      new_tax_category_modal
      edit_tax_category_modal
    ]
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
      {
        header: :name,
        data: ->(tax_category) do
          link_to tax_category.name, edit_path(tax_category), class: "body-link"
        end
      },
      {
        header: :tax_code,
        data: ->(tax_category) do
          link_to_if tax_category.tax_code, tax_category.tax_code, edit_path(tax_category), class: "body-link"
        end
      },
      {
        header: :description,
        data: ->(tax_category) do
          link_to tax_category.description, edit_path(tax_category), class: "body-link"
        end
      },
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
