# Interface for accessing and updating a user's active "wallet". A Wallet
# is the *active* list of *reusable* payment sources that a user would like to
# choose from when placing orders.
#
# A Wallet is composed of WalletSources. A WalletSource is a join table that
# links a PaymentSource (e.g. a CreditCard) to a User.  One of a user's
# WalletSources may be the 'default' WalletSource.
class Spree::Wallet
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Returns an array of the WalletSources in this wallet.
  #
  # @return [Array<WalletSource>]
  def wallet_sources
    user.wallet_sources.to_a
  end

  # Add a PaymentSource to the wallet.
  #
  # @param source [PaymentSource] The payment source to add to the wallet
  # @return [WalletSource] the generated WalletSource
  def add(source)
    user.wallet_sources.find_or_create_by!(source: source)
  end

  # Remove a PaymentSource to the wallet.
  #
  # @param source [PaymentSource] The payment source to remove from the wallet
  # @raise [ActiveRecord::RecordNotFound] if the source is not in the wallet.
  # @return [WalletSource] the destroyed WalletSource
  def remove(source)
    user.wallet_sources.find_by!(source: source).destroy!
  end

  # Find a WalletSource in the wallet by id.
  #
  # @param wallet_source_id [Integer] The id of the WalletSource.
  # @return [WalletSource]
  def find(wallet_source_id)
    user.wallet_sources.find_by(id: wallet_source_id)
  end

  # Find the default WalletSource for this wallet, if any.
  # @return [WalletSource]
  def default
    user.wallet_sources.find_by(default: true)
  end

  # Change the default WalletSource for this wallet.
  # @param source [PaymentSource] The payment source to set as the default.
  #   It must be in the wallet already. Pass nil to clear the default.
  # @return [WalletSource] the associated WalletSource, or nil if clearing
  #   the default.
  def default=(source)
    wallet_source = source && user.wallet_sources.find_by!(source: source)
    wallet_source.transaction do
      # Unset old default
      default.try!(:update!, default: false)
      # Set new default
      wallet_source.try!(:update!, default: true)
    end
    wallet_source
  end
end
