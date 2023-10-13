# frozen_string_literal: true

class SolidusAdmin::Products::Stock::Component < SolidusAdmin::BaseComponent
  def self.from_product(product)
    new(
      on_hand: product.total_on_hand,
      variants_count: product.variants.count,
    )
  end

  def initialize(on_hand:, variants_count:)
    @on_hand = on_hand
    @variants_count = variants_count
  end

  def call
    stock_info =
      case @on_hand
      when Float::INFINITY
        tag.span t('.stock.in_stock', on_hand: t('.stock.infinity')), class: 'text-forest'
      when 1..Float::INFINITY
        tag.span t('.stock.in_stock', on_hand: @on_hand), class: 'text-forest'
      else
        tag.span t('.stock.in_stock', on_hand: @on_hand), class: 'text-red-500'
      end

    variant_info = t('.for_variants', count: @variants_count)

    tag.span safe_join([stock_info, variant_info], ' ')
  end
end
