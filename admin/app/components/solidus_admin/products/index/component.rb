# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  def initialize(
    page:,
    status_component: component('products/status'),
    table_component: component('ui/table'),
    pagination_component: component('ui/table/pagination'),
    button_component: component("ui/button")
  )
    @page = page
    @status_component = status_component
    @table_component = table_component
    @button_component = button_component
    @pagination_component = pagination_component
  end

  def title
    Spree::Product.model_name.human.pluralize
  end

  def prev_page_link
    @page.first? ? nil : solidus_admin.url_for(host: request.host, port: request.port, **request.params, page: @page.number - 1)
  end

  def next_page_link
    @page.last? ? nil : solidus_admin.url_for(host: request.host, port: request.port, **request.params, page: @page.next_param)
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.products_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
      {
        display_name: t('.batch_actions.discontinue'),
        action: solidus_admin.discontinue_products_path,
        method: :put,
        icon: 'pause-circle-line',
      },
      {
        display_name: t('.batch_actions.activate'),
        action: solidus_admin.activate_products_path,
        method: :put,
        icon: 'play-circle-line',
      },
    ]
  end

  def filters
    [
      {
        name: 'q[with_discarded]',
        value: true,
        label: t('.filters.with_deleted'),
      },
    ]
  end

  def columns
    [
      image_column,
      name_column,
      status_column,
      price_column,
      stock_column,
    ]
  end

  def image_column
    {
      class_name: "w-[72px]",
      header: tag.span('aria-label': t('.product_image'), role: 'text'),
      data: ->(product) do
        image = product.gallery.images.first or return

        link_to(
          image_tag(image.url(:small), class: 'h-10 w-10 max-w-min rounded border border-gray-100', alt: product.name),
          spree.edit_admin_product_path(product),
          class: 'inline-flex overflow-hidden',
          tabindex: -1,
        )
      end
    }
  end

  def name_column
    {
      header: :name,
      data: ->(product) do
        link_to product.name, spree.edit_admin_product_path(product)
      end
    }
  end

  def status_column
    {
      header: :status,
      data: ->(product) { @status_component.new(product: product) }
    }
  end

  def stock_column
    {
      header: :stock,
      data: ->(product) do
        stock_info =
          case (on_hand = product.total_on_hand)
          when Float::INFINITY
            content_tag :span, t('.stock.in_stock', on_hand: t('.stock.infinity')), class: 'text-forest'
          when 1..Float::INFINITY
            content_tag :span, t('.stock.in_stock', on_hand: on_hand), class: 'text-forest'
          else
            content_tag :span, t('.stock.in_stock', on_hand: on_hand), class: 'text-red-500'
          end

        variant_info =
          t('.for_variants', count: product.variants.count)

        content_tag :div, safe_join([stock_info, variant_info], ' ')
      end
    }
  end

  def price_column
    {
      header: :price,
      data: ->(product) do
        content_tag :div, product.master.display_price.to_html
      end
    }
  end
end
