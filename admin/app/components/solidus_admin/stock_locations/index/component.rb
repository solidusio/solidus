# frozen_string_literal: true

class SolidusAdmin::StockLocations::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::StockLocation.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.stock_locations_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    []
  end

  def scopes
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
