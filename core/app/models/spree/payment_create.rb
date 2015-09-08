module Spree
  class PaymentCreate
    def initialize(order, attributes, payment: nil, request_env: {})
      @order = order
      @payment = payment
      @attributes = attributes.dup
      @source_attributes = attributes.delete(:source_attributes) || {}
      @request_env = request_env
    end

    def build
      @payment ||= order.payments.new
      @payment.request_env = @request_env if @request_env
      @payment.attributes = @attributes

      if source_attributes[:existing_card_id].present?
        build_existing_card
      else
        build_source
      end

      @payment
    end

    private

    attr_reader :order, :payment, :attributes, :source_attributes

    def build_source
      payment_method = payment.payment_method
      if source_attributes.present? && payment_method.try(:payment_source_class)
        payment.source = payment_method.payment_source_class.new(source_attributes)
        payment.source.payment_method_id = payment_method.id
        payment.source.user_id = order.user_id if order
      end
    end

    def build_existing_card
      credit_card = CreditCard.
        where(user_id: order.user_id).
        where.not(user_id: nil).
        find(source_attributes[:existing_card_id])

      # FIXME: does this work?
      if source_attributes[:verification_value]
        credit_card.verification_value = source_attributes[:verification_value]
      end

      payment.source = credit_card
      payment.payment_method_id = credit_card.payment_method_id
    end

  end
end
