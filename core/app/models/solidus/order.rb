module Solidus
  class Order
    attr_accessor :cancellations, :ownership, :payment, :contents

    def initialize(order, behavior=nil)

      behavior ||= Solidus::OrderBehavior.default

      @order = order

      @cancellations = behavior.cancellation.new(self)
      @ownership     = behavior.ownership.new(self)
      @payment       = behavior.payment.new(self)
      @contents      = behavior.contents.new(self)
    end

    # Exposing the old Spree::Order until transition is complete (AKA the sun burns out)
    def model
      @order
    end

    def lock
      model.with_lock do
        yield
      end
    end

  end
end
