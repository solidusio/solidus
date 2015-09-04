module Spree
  class OrderUpdateAttributes
    attr_reader :attributes, :payments_attributes, :order, :request
    def initialize(order, attributes, request_env: nil, request: nil)
      @order = order
      @attributes = attributes.dup
      @payments_attributes = @attributes.delete(:payments_attributes) || []
      @request = request
      @request_env = request_env
      @request_env ||= request.headers.env if request
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
        PaymentCreate.new(order, payment_attributes, request_env: @request_env).build
      end
    end
  end
end
