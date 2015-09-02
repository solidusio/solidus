module Spree
  class OrderUpdateAttributes
    attr_reader :attributes, :order, :request
    def initialize(order, attributes, request_env: nil, request: nil)
      @order = order
      @attributes = attributes
      @request = request
      @request_env = request_env
    end

    def update
      if attributes[:payments_attributes]
        attributes[:payments_attributes].each do |payment_attributes|
          payment_attributes[:request_env] = request_env
        end
      end

      order.attributes = attributes
      if order.save
        order.set_shipments_cost if order.shipments.any?
        true
      else
        false
      end
    end

    private

    def request_env
      @request_env ||= request ? request.headers.env : {}
    end
  end
end
