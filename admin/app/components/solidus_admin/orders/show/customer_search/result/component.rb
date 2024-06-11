# frozen_string_literal: true

class SolidusAdmin::Orders::Show::CustomerSearch::Result::Component < SolidusAdmin::BaseComponent
  with_collection_parameter :customer

  def initialize(order:, customer:)
    @order = order
    @customer = customer
    @name = (customer.default_user_bill_address || customer.default_user_ship_address)&.address&.name if customer
  end
end
