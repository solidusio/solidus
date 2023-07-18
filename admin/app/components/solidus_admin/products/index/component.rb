# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  def initialize(page:, columns: container["products.index"])
    @page = page
    @columns = columns.map { _1.ensure_render_context(self) }
  end

  def image_header
    tag.span('aria-label': t(".product_image"), role: 'text')
  end

  def image_column(id, image)
    image or return

    link_to(
      image_tag(image.url(:small), class: 'h-10 w-10 max-w-min'),
      spree.edit_admin_product_path(id),
    )
  end

  def name_column(id, name)
    link_to name, spree.edit_admin_product_path(id)
  end

  def status_column(available)
    if available
      component('ui/badge').new(name: t('.status.available'), color: :green)
    else
      component('ui/badge').new(name: t('.status.discontinued'), color: :red)
    end
  end

  def stock_column(on_hand, variants_count)
    stock_info =
      case on_hand
      when Float::INFINITY
        content_tag :span, t('.stock.in_stock', on_hand: t('.stock.infinity')), class: 'text-forest'
      when 1..Float::INFINITY
        content_tag :span, t('.stock.in_stock', on_hand: on_hand), class: 'text-forest'
      else
        content_tag :span, t('.stock.in_stock', on_hand: on_hand), class: 'text-red-500'
      end

    variant_info =
      t('.for_variants', count: variants_count)

    safe_join([stock_info, variant_info], ' ')
  end

  def price_column(price)
    price.to_html
  end
end
