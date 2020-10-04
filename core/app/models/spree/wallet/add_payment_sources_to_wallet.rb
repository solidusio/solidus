# frozen_string_literal: true

# This class is responsible for saving payment sources in the user's "wallet"
# for future use.  You can substitute your own class via
# `Spree::Config.add_payment_sources_to_wallet_class`.
class Spree::Wallet::AddPaymentSourcesToWallet
  def initialize(order)
    @order = order
  end

  # This is called after an order transistions to complete and should save the
  # order's payment source in the user's "wallet" for future use.
  #
  # @return [void]
  def add_to_wallet
    if !order.temporary_payment_source && order.user
      # select valid sources
      payments = order.payments.valid
      sources = payments.map(&:source).
        uniq.
        compact.
        select { |payment| payment.try(:reusable?) }

      # add valid sources to wallet and optionally set a default
      if sources.any?
        # arbitrarily sort by id for picking a default
        sources.sort_by(&:id).each do |source|
          order.user.wallet.add(source)
        end

        make_default
      end
    end
  end

  protected

  def make_default
    order.user.wallet.default_wallet_payment_source = order.user.wallet_payment_sources.last
  end

  private

  attr_reader :order
end
