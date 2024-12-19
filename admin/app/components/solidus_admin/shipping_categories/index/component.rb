# frozen_string_literal: true

class SolidusAdmin::ShippingCategories::Index::Component < SolidusAdmin::Shipping::Component
  def model_class
    Spree::ShippingCategory
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_shipping_category_path, data: {
        action: "click->ui--pages--index#openModal"
      },
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def edit_url(shipping_category)
    spree.edit_admin_shipping_category_path(shipping_category)
  end

  def search_key
    :name_cont
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
      {
        header: :name,
        data: ->(shipping_category) do
          link_to shipping_category.name, edit_url(shipping_category),
            data: { action: "click->ui--pages--index#openModal" },
            class: "body-link"
        end
      },
    ]
  end
end
