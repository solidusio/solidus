# frozen_string_literal: true

class SolidusAdmin::Products::Status::Component < SolidusAdmin::BaseComponent
  COLORS = {
    available: :green,
    discontinued: :red
  }.freeze

  # @param product [Spree::Product]
  def initialize(product:, badge_component: component('ui/badge'))
    @product = product
    @badge_component = badge_component
  end

  def call
    render @badge_component.new(
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
