class Spree::WalletSource < ActiveRecord::Base
  belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id', inverse_of: :wallet_sources
  belongs_to :source, polymorphic: true, inverse_of: :wallet_sources

  validates_presence_of :user
  validates_presence_of :source
end
