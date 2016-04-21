class Spree::Wallet::AddDefaultPayment
  def initialize(order)
    @order = order
  end

  # Build a payment to be added to an order prior to moving into the "payment"
  # state.
  #
  # @return [Payment] the unsaved payment to be added, or nil if none.
  def build_payment
    # TODO: verify that this works with store credits:
    return if order.payments.valid.present?

    if default = order.user.try!(:wallet).try!(:default)
      Spree::Payment.new(
        payment_method: default.source.payment_method,
        source: default.source,
      )
    end
  end

  private

  attr_reader :order
end
