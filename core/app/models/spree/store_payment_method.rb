module Spree
  class StorePaymentMethod < ActiveRecord::Base
    belongs_to :store, inverse_of: :store_payment_methods
    belongs_to :payment_method, inverse_of: :store_payment_methods
  end
end
