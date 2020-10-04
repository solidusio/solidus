# frozen_string_literal: true

module Spree
  class UserAddress < Spree::Base
    belongs_to :user, class_name: UserClassHandle.new, foreign_key: "user_id", optional: true
    belongs_to :address, class_name: "Spree::Address", optional: true

    validates_uniqueness_of :address_id, scope: :user_id
    validates_uniqueness_of :user_id, conditions: -> { active.default_shipping }, message: :default_address_exists, if: :default?

    scope :with_address_values, ->(address_attributes) do
      joins(:address).merge(
        Spree::Address.with_values(address_attributes)
      )
    end

    scope :all_historical, -> { unscope(where: :archived) }
    scope :default_shipping, -> { where(default: true) }
    scope :default_billing, -> { where(default_billing: true) }
    scope :active, -> { where(archived: false) }

    scope :default, -> do
      Spree::Deprecation.warn "This scope is deprecated. Please start using ::default_shipping."
      default_shipping
    end

    default_scope -> { order([default: :desc, updated_at: :desc]) }
  end
end
