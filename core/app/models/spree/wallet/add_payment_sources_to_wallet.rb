# This class is responsible for saving payment sources in the user's "wallet"
# for future use.  You can substitute your own class via
# `Spree::Config.add_payment_sources_to_wallet_class`.
class Spree::Wallet::AddPaymentSourcesToWallet
  def initialize(order)
    @order = order
  end

  # This is called after an order transistions to complete and should save the
  # order's payment source/s in the user's "wallet" for future use.
  #
  # @return [undefined]
  def add_to_wallet
    if !order.temporary_credit_card &&
       order.user_id &&
       order.valid_credit_cards.present?
      # arbitrarily pick the first one for the default
      default_cc = order.valid_credit_cards.first
      # TODO: target for refactoring -- why is order checkout responsible for the user -> credit_card relationship?
      default_cc.user_id = order.user_id
      default_cc.default = true
      default_cc.save
    end
  end

  private

  attr_reader :order
end
