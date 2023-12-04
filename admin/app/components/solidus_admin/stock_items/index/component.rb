# frozen_string_literal: true

class SolidusAdmin::StockItems::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::StockItem.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    []
  end

  def scopes
    [
      { label: t('.scopes.all_stock_items'), name: 'all', default: true },
      { label: t('.scopes.back_orderable'), name: 'back_orderable' },
      { label: t('.scopes.out_of_stock'), name: 'out_of_stock' },
      { label: t('.scopes.low_stock'), name: 'low_stock' },
      { label: t('.scopes.in_stock'), name: 'in_stock' },
    ]
  end

  def filters
    [
      {
        presentation: t('.filters.stock_locations'),
        combinator: 'or',
        attribute: "stock_location_id",
        predicate: "eq",
        options: Spree::StockLocation.all.map do |stock_location|
          [
            stock_location.name.titleize,
            stock_location.id
          ]
        end
      },
      {
        presentation: t('.filters.variants'),
        combinator: 'or',
        attribute: "variant_id",
        predicate: "eq",
        options: Spree::Variant.all.map do |variant|
          [
            variant.descriptive_name,
            variant.id
          ]
        end
      },
    ]
  end

  def columns
    [
      image_column,
      name_column,
      sku_column,
      variant_column,
      stock_location_column,
      back_orderable_column,
      count_on_hand_column,
    ]
  end

  def image_column
    {
      col: { class: "w-[72px]" },
      header: tag.span('aria-label': t('.image'), role: 'text'),
      data: ->(stock_item) do
        image = stock_item.variant.gallery.images.first or return

        render(
          component('ui/thumbnail').new(
            src: image.url(:small),
            alt: stock_item.variant.name
          )
        )
      end
    }
  end

  def name_column
    {
      header: :name,
      data: ->(stock_item) do
        content_tag :div, stock_item.variant.name
      end
    }
  end

  def sku_column
    {
      header: :sku,
      data: ->(stock_item) do
        content_tag :div, stock_item.variant.sku
      end
    }
  end

  def variant_column
    {
      header: :variant,
      data: ->(stock_item) do
        content_tag(:div, class: "space-y-0.5") do
          safe_join(
            stock_item.variant.option_values.sort_by(&:option_type_name).map do |option_value|
              render(component('ui/badge').new(name: "#{option_value.option_type_presentation}: #{option_value.presentation}"))
            end
          )
        end
      end
    }
  end

  def stock_location_column
    {
      header: :stock_location,
      data: ->(stock_item) do
        link_to stock_item.stock_location.name, spree.admin_stock_location_stock_movements_path(stock_item.stock_location.id, q: { variant_sku_eq: stock_item.variant.sku })
      end
    }
  end

  def back_orderable_column
    {
      header: :back_orderable,
      data: ->(stock_item) do
        stock_item.backorderable? ? component('ui/badge').yes : component('ui/badge').no
      end
    }
  end

  def count_on_hand_column
    {
      header: :count_on_hand,
      data: ->(stock_item) do
        content_tag :div, stock_item.count_on_hand
      end
    }
  end
end
