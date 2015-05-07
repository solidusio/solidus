module Solidus
  class Order
    attr_accessor :cancellations, :ownership

    def initialize(order, cancellations: nil, ownership: nil, payments: nil)
      @order = order

      @cancellations ||= Spree::OrderCancellations.new(order)
      @ownership     ||= Solidus::Ownership.new(self)
      @payments      ||= Solidus::Payment.new(self)
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
