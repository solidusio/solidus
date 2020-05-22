# frozen_string_literal: true

class Spree::StoreCreditReason < Spree::Base
  include Spree::NamedType

  has_many :store_credit_events, inverse_of: :store_credit_reason
end
