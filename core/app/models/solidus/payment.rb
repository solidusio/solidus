module Solidus
  # Responsible for handling payment handling and processing
  class Payment

    def initialize order
      @order = order
    end

    # returns list of Spree::Payment's on an order
    def payments
      @order.model.payments
    end

    def add_payment payment
      @order.lock do
        @order.model.payments << payment
      end
    end

    def capture payment
      payment.capture!
    end

  end
end

