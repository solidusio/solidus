# frozen_string_literal: true

class SolidusAdmin::StockLocations::Index::Component < SolidusAdmin::Shipping::Component
  def model_class
    Spree::StockLocation
  end

  def actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_stock_location_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def row_url(stock_location)
    spree.edit_admin_stock_location_path(stock_location)
  end

  def search_url
    solidus_admin.stock_locations_path
  end

  def search_key
    :name_or_description_cont
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.stock_locations_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    []
  end

  def filters
    []
  end

  def columns
    [
      :name,
      :code,
      :admin_name,
      {
        header: :state,
        data: -> {
          color = _1.active? ? :green : :graphite_light
          text = _1.active? ? t('.active') : t('.inactive')

          component('ui/badge').new(name: text, color: color)
        },
      },
      {
        header: :backorderable,
        data: -> {
          _1.backorderable_default ? component('ui/badge').yes : component('ui/badge').no
        }
      },
      {
        header: :default,
        data: -> {
          _1.default ? component('ui/badge').yes : component('ui/badge').no
        }
      },
      {
        header: :stock_movements,
        data: -> {
          count = _1.stock_movements.count

          link_to(
            "#{count} #{Spree::StockMovement.model_name.human(count: count).downcase}",
            spree.admin_stock_location_stock_movements_path(_1),
            class: 'body-link'
          )
        }
      }
    ]
  end
end
