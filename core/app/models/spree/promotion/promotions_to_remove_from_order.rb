# This class is responsible for selecting which promotions should be removed
# from an order after a new promotion has been activated on the order.
# This default class does not remove any promotions from the order. You can
# substitute your own class via
# `Spree::Config.promotions_to_remove_from_order_class`.
#
# Example of customization: Only allowing the most recently applied promotion to
# be kept on an order.
class Spree::Promotion::PromotionsToRemoveFromOrder
  # @param order [Spree::Order] The order we are choosing promotions for.
  def initialize(order)
    @order = order
  end

  # Select which promotions should be removed from the order.
  #
  # @return [Array<Spree::Promotion>] the promotions to remove from the order.
  def promotions_to_remove
    []
  end

  private

  attr_accessor :order
end
