# frozen_string_literal: true

class SolidusAdmin::Products::Status::Component < SolidusAdmin::BaseComponent
  STATUSES = {
    available: :green,
    discontinued: :red
  }.freeze

  def self.from_product(product)
    new(status: product.available? ? :available : :discontinued)
  end

  def initialize(status:)
    @status = status
  end

  def call
    render component('ui/badge').new(
      name: t(".#{@status}"),
      color: STATUSES.fetch(@status)
    )
  end
end
