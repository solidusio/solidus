# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  def initialize(
    page:,
    badge_component: component('ui/badge'),
    table_component: component('ui/table'),
    button_component: component("ui/button")
  )
    @page = page

    @badge_component = badge_component
    @table_component = table_component
    @button_component = button_component
  end

  def image_column(product)
    image = product.gallery.images.first or return

    link_to(
      image_tag(image.url(:small), class: 'h-10 w-10 max-w-min rounded border border-gray-100', alt: product.name),
      spree.edit_admin_product_path(product),
      class: 'inline-flex overflow-hidden',
      tabindex: -1,
    )
  end

  def name_column(product)
    link_to product.name, spree.edit_admin_product_path(product)
  end

  def status_column(product)
    if product.available?
      @badge_component.new(name: t('.status.available'), color: :green)
    else
      @badge_component.new(name: t('.status.discontinued'), color: :red)
    end
  end

  def stock_column(product)
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

    safe_join([stock_info, variant_info], ' ')
  end

  def price_column(product)
    content_tag :div, product.master.display_price.to_html
  end
end
