# frozen_string_literal: true

class SolidusAdmin::ShippingCategories::Index::Component < SolidusAdmin::Shipping::Component
  def model_class
    Spree::ShippingCategory
  end

  def actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_shipping_category_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def row_url(shipping_category)
    spree.edit_admin_shipping_category_path(shipping_category)
  end

  def search_key
    :name_or_description_cont
  end

  def search_url
    solidus_admin.shipping_categories_path
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.shipping_categories_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      :name
    ]
  end
end
