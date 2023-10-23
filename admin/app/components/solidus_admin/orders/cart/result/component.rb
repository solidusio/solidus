# frozen_string_literal: true

class SolidusAdmin::Orders::Cart::Result::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :variant

  def initialize(order:, variant:)
    @order = order
    @variant = variant
    @image = @variant.images.first || @variant.product.gallery.images.first
  end
end
