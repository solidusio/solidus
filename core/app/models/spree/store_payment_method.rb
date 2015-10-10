module Spree
  class StorePaymentMethod < Spree::Base
    belongs_to :store, inverse_of: :store_payment_methods
    belongs_to :payment_method, inverse_of: :store_payment_methods
  end
end
