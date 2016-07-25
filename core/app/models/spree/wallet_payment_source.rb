class Spree::WalletPaymentSource < ActiveRecord::Base
  belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
  belongs_to :payment_source, polymorphic: true

  validates_presence_of :user
  validates_presence_of :payment_source
end
