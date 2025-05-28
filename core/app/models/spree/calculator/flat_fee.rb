# frozen_string_literal: true

require_dependency "spree/calculator"

module Spree
  # Very simple tax rate calculator. Can be used to apply a flat fee to any
  # type of item, including an order.
  class Calculator::FlatFee < Calculator
    alias_method :rate, :calculable

    # Amount is fixed regardles of what it's being applied to.
    def compute(_object)
      rate.active? ? rate.amount : 0
    end

    alias_method :compute_order, :compute
    alias_method :compute_shipment, :compute
    alias_method :compute_line_item, :compute
    alias_method :compute_shipping_rate, :compute
  end
end
