# frozen_string_literal: true

module Solidus
  class StoreCreditType < Solidus::Base
    EXPIRING = 'Expiring'
    NON_EXPIRING = 'Non-expiring'
    DEFAULT_TYPE_NAME = EXPIRING
    has_many :store_credits, class_name: 'Solidus::StoreCredit', foreign_key: 'type_id'
  end
end
