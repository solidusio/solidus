module Spree
  class StoreCreditType < ActiveRecord::Base
    DEFAULT_TYPE_NAME = Spree.t("store_credit.expiring")
    has_many :store_credits, class_name: 'Spree::StoreCredit', foreign_key: 'type_id'
  end
end
