class Spree::WalletSource < ActiveRecord::Base
  belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
  belongs_to :source, polymorphic: true

  validates_presence_of :user
  validates_presence_of :source
end
