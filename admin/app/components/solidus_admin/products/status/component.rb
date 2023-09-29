# frozen_string_literal: true

class SolidusAdmin::Products::Status::Component < SolidusAdmin::BaseComponent
  COLORS = {
    available: :green,
    discontinued: :red
  }.freeze

  # @param product [Spree::Product]
  def initialize(product:)
    @product = product
  end

  def call
    render component('ui/badge').new(
      name: t(".#{status}"),
      color: COLORS.fetch(status)
    )
  end

  # @return [Symbol]
  #   :available when the product is available
  #   :discontinued when the product is not available
  def status
    if @product.available?
      :available
    else
      :discontinued
    end
  end
end
