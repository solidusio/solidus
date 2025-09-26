# frozen_string_literal: true

module Spree
  class UserAddress < Spree::Base
    belongs_to :user, class_name: UserClassHandle.new, foreign_key: "user_id", inverse_of: :user_addresses
    belongs_to :address, class_name: "Spree::Address"

    validates :address_id, uniqueness: {scope: :user_id}
    validates :user_id, uniqueness: {conditions: -> { default_shipping }, message: :default_address_exists, if: :default?}

    scope :with_address_values, ->(address_attributes) do
      joins(:address).merge(
        Spree::Address.with_values(address_attributes)
      )
    end

    scope :all_historical, -> {
      Spree.deprecator.warn("The 'Spree::UserAddress.all_historical` scope does not do anything and will be removed from Solidus 5.")
      all
    }
    scope :default_shipping, -> { where(default: true) }
    scope :default_billing, -> { where(default_billing: true) }
    scope :active, -> {
      Spree.deprecator.warn("The 'Spree::UserAddress.active` scope does not do anything and will be removed from Solidus 5.")
      all
    }

    default_scope -> { order([default: :desc, updated_at: :desc]) }
  end
end
