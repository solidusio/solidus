class Spree::WalletPaymentSource < ActiveRecord::Base
  belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id', inverse_of: :wallet_payment_sources
  belongs_to :payment_source, polymorphic: true, inverse_of: :wallet_payment_sources

  validates_presence_of :user
  validates_presence_of :payment_source
end
