# frozen_string_literal: true

class SolidusAdmin::ShippingMethods::Index::Component < SolidusAdmin::Shipping::Component
  def model_class
    Spree::ShippingMethod
  end

  def edit_path(shipping_method)
    solidus_admin.edit_shipping_method_path(shipping_method)
  end

  def search_url
    solidus_admin.shipping_methods_path
  end

  def search_key
    :name_or_description_cont
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_shipping_method_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.shipping_methods_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      name_column,
      zone_column,
      calculator_column,
      available_to_users_column,
    ]
  end

  private

  def name_column
    {
      header: :name,
      data: ->(shipping_method) do
        name = [shipping_method.admin_name.presence, shipping_method.name].compact.join(' / ')
        link_to name, edit_path(shipping_method), class: 'body-link'
      end
    }
  end

  def zone_column
    {
      header: :zone,
      data: ->(shipping_method) do
        shipping_method.zones.pluck(:name).to_sentence
      end
    }
  end

  def calculator_column
    {
      header: :calculator,
      data: ->(shipping_method) do
        shipping_method.calculator&.description
      end
    }
  end

  def available_to_users_column
    {
      header: :available_to_users,
      data: ->(shipping_method) do
        shipping_method.available_to_users? ? component('ui/badge').yes : component('ui/badge').no
      end
    }
  end
end
