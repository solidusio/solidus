class MoveCreditCardDefaultToWalletPaymentSource < ActiveRecord::Migration[4.2]
  def up
    credit_cards = Spree::CreditCard.
      where(default: true).
      where.not(user_id: nil)

    credit_cards.find_each do |credit_card|
      Spree::WalletPaymentSource.create!(
        user_id: credit_card.user_id,
        payment_source: credit_card,
        default: credit_card.read_attribute(:default),
      )
    end

    remove_column :spree_credit_cards, :default, :boolean
  end

  def down
    add_column :spree_credit_cards, :default, :boolean, default: false, null: false

    wallet_payment_sources = Spree::WalletPaymentSource.
      where(default: true, source_type: 'Spree::CreditCard').
      includes(:source)

    wallet_payment_sources.find_each do |wallet_payment_source|
      credit_card = wallet_payment_source.payment_source
      credit_card.update!(default: true)
    end
  end
end
