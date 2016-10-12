# This class is responsible for deciding whether to *attempt* to apply an
# "apply_automatically" promotion to an order.
#
# This default class always returns true. You can substitute your own class via
# `Spree::Config.automatic_promotion_decision_class`.
#
# One example scenario that this is meant to support (via customization):
# A store that only allows a single promotion per order, and doesn't want
# "apply_automatically" promotions to be attempted if an order already has a
# promotion attached to it.
#
# Promotion eligibility rules will also be checked after this if this returns
# true.
class Spree::Promotion::AutomaticPromotionDecision
  # @param order [Spree::Order] the order the promotion would be applied to
  # @param promotion [Spree::Promotion] the "apply_automatically" promotion
  def initialize(order:, promotion:)
    @order = order
    @promotion = promotion
  end

  # @return [Boolean] whether we should attempt to apply the promotion to the
  #  order.
  def attempt_to_apply?
    true
  end

  private

  attr_accessor :order, :promotion
end
