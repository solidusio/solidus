# frozen_string_literal: true

module Spree
  class StoreCreditType < Spree::Base
    EXPIRING = 'Expiring'
    NON_EXPIRING = 'Non-expiring'
    DEFAULT_TYPE_NAME = EXPIRING
    has_many :store_credits, class_name: 'Spree::StoreCredit', foreign_key: 'type_id'
  end
end
