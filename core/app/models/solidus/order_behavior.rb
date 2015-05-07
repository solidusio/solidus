module Solidus
  class OrderBehavior
    cattr_accessor :default do
      Solidus::OrderBehavior.new
    end

    def cancellation
      Spree::OrderCancellations
    end

    def payment
      Solidus::Payment
    end

    def ownership
      Solidus::Ownership
    end

    def contents
      Spree::OrderContents
    end
  end
end
