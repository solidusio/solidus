module Spree
  # Service object for creating new payments on an Order
  class PaymentCreate
    # @param order [Order] The order for the new payment
    # @param attributes [Hash,ActionController::Parameters] attributes which are assigned to the new payment
    #   * :payment_method_id Id of payment method used for this payment
    #   * :source_attributes Attributes used to build the source of this payment. Usually a {CreditCard}
    #     * :existing_card_id (Integer) The id of an existing {CreditCard} object to use
    # @param request_env [Hash] rack env of user creating the payment
    # @param payment [Payment] Internal use only. Instead of making a new payment, change the attributes for an existing one.
    def initialize(order, attributes, payment: nil, request_env: {})
      @order = order
      @payment = payment

      # If AC::Params are passed in, attributes.to_h gives us a hash of only
      # the permitted attributes.
      @attributes = attributes.to_h.with_indifferent_access
      @source_attributes = @attributes.delete(:source_attributes) || {}
      @request_env = request_env
    end

    # Build the new Payment
    # @return [Payment] a new (unpersisted) Payment
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
      credit_card = available_cards.find(source_attributes[:existing_card_id])

      # FIXME: does this work?
      if source_attributes[:verification_value]
        credit_card.verification_value = source_attributes[:verification_value]
      end

      payment.source = credit_card
      payment.payment_method_id = credit_card.payment_method_id
    end

    def available_cards
      if user_id = order.user_id
        CreditCard.where(user_id: user_id)
      else
        CreditCard.none
      end
    end
  end
end
