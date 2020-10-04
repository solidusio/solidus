# frozen_string_literal: true

module Spree
  class StorePaymentMethod < Spree::Base
    belongs_to :store, inverse_of: :store_payment_methods, optional: true
    belongs_to :payment_method, inverse_of: :store_payment_methods, optional: true
  end
end
