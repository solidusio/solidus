# frozen_string_literal: true

class SolidusAdmin::StockLocations::Index::Component < SolidusAdmin::Shipping::Component
  def model_class
    Spree::StockLocation
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_stock_location_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def search_url
    solidus_admin.stock_locations_path
  end

  def search_key
    :name_or_description_cont
  end

  def edit_path(stock_location)
    spree.edit_admin_stock_location_path(stock_location)
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
      name_column,
      code_column,
      admin_name_column,
      state_column,
      backorderable_column,
      default_column,
      stock_movements_column,
    ]
  end

  private

  def name_column
    {
      header: :name,
      data: ->(stock_location) do
        link_to stock_location.name, edit_path(stock_location), class: 'body-link'
      end
    }
  end

  def code_column
    {
      header: :code,
      data: ->(stock_location) do
        return if stock_location.code.blank?
        link_to stock_location.code, edit_path(stock_location), class: 'body-link'
      end
    }
  end

  def admin_name_column
    {
      header: :admin_name,
      data: ->(stock_location) do
        return if stock_location.admin_name.blank?
        link_to stock_location.admin_name, edit_path(stock_location), class: 'body-link'
      end
    }
  end

  def state_column
    {
      header: :state,
      data: ->(stock_location) do
        color = stock_location.active? ? :green : :graphite_light
        text = stock_location.active? ? t('.active') : t('.inactive')

        component('ui/badge').new(name: text, color:)
      end
    }
  end

  def backorderable_column
    {
      header: :backorderable,
      data: -> do
        _1.backorderable_default ? component('ui/badge').yes : component('ui/badge').no
      end
    }
  end

  def default_column
    {
      header: :default,
      data: -> do
        _1.default ? component('ui/badge').yes : component('ui/badge').no
      end
    }
  end

  def stock_movements_column
    {
      header: :stock_movements,
      data: ->(stock_location) do
        count = stock_location.stock_movements.count

        link_to(
          "#{count} #{Spree::StockMovement.model_name.human(count:).downcase}",
          spree.admin_stock_location_stock_movements_path(stock_location),
          class: 'body-link'
        )
      end
    }
  end
end
