# frozen_string_literal: true

module Spree
  # Service object for creating new payments on an Order
  class PaymentCreate
    # @param order [Order] The order for the new payment
    # @param attributes [Hash,ActionController::Parameters] attributes which are assigned to the new payment
    #   * :payment_method_id Id of payment method used for this payment
    #   * :source_attributes Attributes used to build the source of this payment. Usually a {CreditCard}
    #     * :existing_card_id (Integer) Deprecated: The id of an existing {CreditCard} object to use
    #     * :wallet_payment_source_id (Integer): The id of a {WalletPaymentSource} to use
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
        Spree::Deprecation.warn(
          "Passing existing_card_id to PaymentCreate is deprecated. Use wallet_payment_source_id instead.",
          caller,
        )
        build_existing_card
      elsif source_attributes[:wallet_payment_source_id].present?
        build_from_wallet_payment_source
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
        if order && payment.source.respond_to?(:user=)
          payment.source.user = order.user
        end
      end
    end

    def build_from_wallet_payment_source
      wallet_payment_source_id = source_attributes.fetch(:wallet_payment_source_id)
      raise(ActiveRecord::RecordNotFound) if order.user.nil?
      wallet_payment_source = order.user.wallet.find(wallet_payment_source_id)
      raise(ActiveRecord::RecordNotFound) if wallet_payment_source.nil?
      build_from_payment_source(wallet_payment_source.payment_source)
    end

    def build_existing_card
      credit_card = available_cards.find(source_attributes[:existing_card_id])
      build_from_payment_source(credit_card)
    end

    def build_from_payment_source(payment_source)
      # FIXME: does this work?
      if source_attributes[:verification_value]
        payment_source.verification_value = source_attributes[:verification_value]
      end

      payment.source = payment_source
      payment.payment_method_id = payment_source.payment_method_id
    end

    def available_cards
      if user_id = order.user_id
        Spree::CreditCard.where(user_id: user_id)
      else
        Spree::CreditCard.none
      end
    end
  end
end
