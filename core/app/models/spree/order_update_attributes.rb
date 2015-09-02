module Spree
  class OrderUpdateAttributes
    attr_reader :attributes, :payments_attributes, :order, :request
    def initialize(order, attributes, request_env: nil, request: nil)
      @order = order
      @attributes = attributes.dup
      @payments_attributes = @attributes.delete(:payments_attributes) || []
      @request = request
      @request_env = request_env
    end

    def update
      assign_payments_attributes
      assign_order_attributes

      if order.save
        order.set_shipments_cost if order.shipments.any?
        true
      else
        false
      end
    end

    private
    def assign_order_attributes
      order.attributes = attributes
    end

    def assign_payments_attributes
      @payments_attributes.each do |payment_attributes|
        payment_attributes = payment_attributes.merge(request_env: request_env)
        order.payments.new(payment_attributes)
      end
    end

    def request_env
      @request_env ||= request ? request.headers.env : {}
    end
  end
end
