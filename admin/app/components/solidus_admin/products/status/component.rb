# frozen_string_literal: true

class SolidusAdmin::Products::Status::Component < SolidusAdmin::BaseComponent
  STATUSES = {
    available: :green,
    discontinued: :yellow,
    deleted: :red,
  }.freeze

  def self.from_product(product)
    status =
      if product.deleted?
        :deleted
      elsif product.discontinued?
        :discontinued
      else
        :available
      end

    new(status: status)
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
