# frozen_string_literal: true

class SolidusAdmin::ShippingMethods::Index::Component < SolidusAdmin::Shipping::Component
  def model_class
    Spree::ShippingMethod
  end

  def row_url(shipping_method)
    spree.edit_admin_shipping_method_path(shipping_method)
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
      href: spree.new_admin_shipping_method_path,
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
      {
        header: :name,
        data: -> { [_1.admin_name.presence, _1.name].compact.join(' / ') },
      },
      {
        header: :zone,
        data: -> { _1.zones.pluck(:name).to_sentence },
      },
      {
        header: :calculator,
        data: -> { _1.calculator&.description },
      },
      {
        header: :available_to_users,
        data: -> { _1.available_to_users? ? component('ui/badge').yes : component('ui/badge').no },
      },
    ]
  end
end
