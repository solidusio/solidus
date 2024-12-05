# frozen_string_literal: true

class SolidusAdmin::StockItems::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::StockItem
  end

  def search_key
    :variant_product_name_or_variant_sku_or_variant_option_values_name_or_variant_option_values_presentation_cont
  end

  def search_url
    solidus_admin.stock_items_path
  end

  def row_url(stock_item)
    edit_path(stock_item)
  end

  def edit_path(stock_item)
    solidus_admin.edit_stock_item_path(stock_item)
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
        label: t('.filters.stock_locations'),
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
        label: t('.filters.variants'),
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
      stock_movements_column,
    ]
  end

  def image_column
    {
      col: { class: "w-[72px]" },
      header: tag.span('aria-label': Spree::Image.model_name.human, role: 'text'),
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
        link_to stock_item.variant.name, edit_path(stock_item), class: "body-link"
      end
    }
  end

  def sku_column
    {
      header: :sku,
      data: ->(stock_item) do
        link_to stock_item.variant.sku, edit_path(stock_item), class: "body-link"
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
      data: ->(stock_item) { stock_item.stock_location.name },
    }
  end

  # Cache the stock movement counts to avoid N+1 queries
  def stock_movement_counts
    @stock_movement_counts ||= Spree::StockMovement.where(stock_item_id: @page.records.ids).group(:stock_item_id).count
  end

  def stock_movements_column
    {
      header: :stock_movements,
      data: -> do
        count = stock_movement_counts[_1.id] || 0

        link_to(
          "#{count} #{Spree::StockMovement.model_name.human(count:).downcase}",
          spree.admin_stock_location_stock_movements_path(
            _1.stock_location.id,
            q: { variant_sku_eq: _1.variant.sku },
          ),
          class: 'body-link'
        )
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

  def turbo_frames
    %w[edit_stock_item_modal]
  end
end
