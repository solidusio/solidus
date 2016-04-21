class Spree::Wallet::AddAfterOrderComplete
  def initialize(order)
    @order = order
  end

  # AddAfterOrderComplete is called after an order transitions to complete. It
  # is responsible for saving payment sources in the user's "wallet" for future
  # use.
  def add_to_wallet
    if !order.temporary_payment_source && order.user
      # select valid sources
      sources = order.payments.valid.map(&:source).uniq.compact.select(&:reusable?)

      # add valid sources to wallet and optionally set a default
      if sources.any?
        sources.each do |source|
          order.user.wallet.add(source)
        end

        # arbitrarily pick the last one for the default
        default_source = sources.sort_by(&:id).last
        order.user.wallet.default = default_source
      end
    end
  end

  private

  attr_reader :order
end
