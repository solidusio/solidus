# frozen_string_literal: true

# This class is responsible for building a default payment on an order, using a
# payment source that is already in the user's "wallet" and is marked
# as being the default payment source.
class Spree::Wallet::DefaultPaymentBuilder
  def initialize(order)
    @order = order
  end

  # Build a payment to be added to an order prior to moving into the "payment"
  # state.
  #
  # @return [Payment] the unsaved payment to be added, or nil if none.
  def build
    default = order.user.try!(:wallet).try!(:default_wallet_payment_source)
    if default && order.payments.where(source_type: default.payment_source_type).none?
      Spree::Payment.new(
        payment_method: default.payment_source.payment_method,
        source: default.payment_source,
      )
    end
  end

  private

  attr_reader :order
end
