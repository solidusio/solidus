module Spree
  class OrderInterface
    attr_reader :order

    def initialize(order)
      @order = order
    end

    delegate :add, :remove, :update_cart, to: :contents

    def associate_user(user, override_email: true)
      Spree::Actions::AssociateUser.new(order, user, override_email: override_email).call
    end

    def capture_payment(payment, amount: nil)
      Spree::Actions::CapturePayment.new(payment, amount: amount).call
    end

    private
    def contents
      Order::Contents.new(contents)
    end
  end
end
