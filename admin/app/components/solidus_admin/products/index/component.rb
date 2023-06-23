# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  def initialize(products:)
    @products = products
  end

  def image_column(product)
    image = product.gallery.images.first or return

    link_to(
      image_tag(image.url(:small), class: 'h-10 w-10 max-w-min'),
      spree.edit_admin_product_path(product),
    )
  end

  def name_column(product)
    link_to product.name, spree.edit_admin_product_path(product)
  end

  def status_column(product)
    if product.available?
      component('ui/badge').new(name: t('.status.available'), color: :green)
    else
      component('ui/badge').new(name: t('.status.discontinued'), color: :red)
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
    product.master.display_price.to_html
  end
end
