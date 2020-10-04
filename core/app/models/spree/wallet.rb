# frozen_string_literal: true

# Interface for accessing and updating a user's active "wallet". A Wallet
# is the *active* list of *reusable* payment sources that a user would like to
# choose from when placing orders.
#
# A Wallet is composed of WalletPaymentSources. A WalletPaymentSource is a join table that
# links a PaymentSource (e.g. a CreditCard) to a User. One of a user's
# WalletPaymentSources may be the 'default' WalletPaymentSource.
class Spree::Wallet
  class Unauthorized < StandardError; end

  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Returns an array of the WalletPaymentSources in this wallet.
  #
  # @return [Array<WalletPaymentSource>]
  def wallet_payment_sources
    user.wallet_payment_sources.to_a
  end

  # Add a PaymentSource to the wallet.
  #
  # @param payment_source [PaymentSource] The payment source to add to the wallet
  # @return [WalletPaymentSource] the generated WalletPaymentSource
  def add(payment_source)
    user.wallet_payment_sources.find_or_create_by!(payment_source: payment_source)
  end

  # Remove a PaymentSource from the wallet.
  #
  # @param payment_source [PaymentSource] The payment source to remove from the wallet
  # @raise [ActiveRecord::RecordNotFound] if the source is not in the wallet.
  # @return [WalletPaymentSource] the destroyed WalletPaymentSource
  def remove(payment_source)
    user.wallet_payment_sources.find_by!(payment_source: payment_source).destroy!
  end

  # Find a WalletPaymentSource in the wallet by id.
  #
  # @param wallet_payment_source_id [Integer] The id of the WalletPaymentSource.
  # @return [WalletPaymentSource]
  def find(wallet_payment_source_id)
    user.wallet_payment_sources.find_by(id: wallet_payment_source_id)
  end

  # Find the default WalletPaymentSource for this wallet, if any.
  # @return [WalletPaymentSource]
  def default_wallet_payment_source
    user.wallet_payment_sources.find_by(default: true)
  end

  # Change the default WalletPaymentSource for this wallet.
  # @param wallet_payment_source [WalletPaymentSource] The payment source to set as the default.
  #   It must be in the wallet already. Pass nil to clear the default.
  # @return [void]
  def default_wallet_payment_source=(wallet_payment_source)
    if wallet_payment_source && !find(wallet_payment_source.id)
      raise Unauthorized, "wallet_payment_source #{wallet_payment_source.id} does not belong to wallet of user #{user.id}"
    end

    # Do not update the payment source if the passed source is already default
    if default_wallet_payment_source == wallet_payment_source
      return
    end

    Spree::WalletPaymentSource.transaction do
      # Unset old default
      default_wallet_payment_source.try!(:update!, default: false)
      # Set new default
      wallet_payment_source.try!(:update!, default: true)
    end
  end
end
