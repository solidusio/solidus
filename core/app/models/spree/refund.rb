# frozen_string_literal: true

module Spree
  class Refund < Spree::Base
    belongs_to :payment, inverse_of: :refunds, optional: true
    belongs_to :reason, class_name: 'Spree::RefundReason', foreign_key: :refund_reason_id, optional: true
    belongs_to :reimbursement, inverse_of: :refunds, optional: true

    has_many :log_entries, as: :source

    validates :payment, presence: true
    validates :reason, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }

    validate :amount_is_less_than_or_equal_to_allowed_amount, on: :create

    attr_accessor :perform_after_create
    after_create :set_perform_after_create_default
    after_create :perform!
    after_create :clear_perform_after_create

    scope :non_reimbursement, -> { where(reimbursement_id: nil) }

    delegate :currency, to: :payment

    def money
      Spree::Money.new(amount, { currency: currency })
    end
    alias display_amount money

    class << self
      def total_amount_reimbursed_for(reimbursement)
        reimbursement.refunds.to_a.sum(&:amount)
      end
    end

    def description
      payment.payment_method.name
    end

    # Must be called for the refund transaction to be processed.
    #
    # Attempts to perform the refund,
    # raises an error if the refund fails.
    def perform!
      return true if perform_after_create == false
      return true if transaction_id.present?

      credit_cents = money.cents

      response = process!(credit_cents)
      log_entries.build(details: response.to_yaml)

      update!(transaction_id: response.authorization)
      update_order
    end

    private

    # This callback takes care of setting the behavior that determines if it is needed
    # to execute the perform! callback after_create.
    # Existing code that creates refund without explicitely passing
    #
    # perform_after_create: false
    #
    # as attribute will still call perform! but a deprecation warning is emitted in order
    # to ask users to change their code with the new supported behavior.
    def set_perform_after_create_default
      return true if perform_after_create == false

      Spree::Deprecation.warn <<-WARN.strip_heredoc, caller
        From Solidus v3.0 onwards, #perform! will need to be explicitly called when creating new
        refunds. Please, change your code from:

          Spree::Refund.create(your: attributes)

        to:

          Spree::Refund.create(your: attributes, perform_after_create: false).perform!
      WARN

      self.perform_after_create = true
    end

    # This is needed to avoid that when you create a refund with perform_after_create = false,
    # it's not possibile to call perform! on that instance, since the value of this attribute
    # will remain false until a reload of the instance.
    def clear_perform_after_create
      @perform_after_create = nil
    end

    # return an activemerchant response object if successful or else raise an error
    def process!(credit_cents)
      response = if payment.payment_method.payment_profiles_supported?
        payment.payment_method.credit(credit_cents, payment.source, payment.transaction_id, { originator: self })
      else
        payment.payment_method.credit(credit_cents, payment.transaction_id, { originator: self })
      end

      if !response.success?
        logger.error(I18n.t('spree.gateway_error') + "  #{response.to_yaml}")
        text = response.params['message'] || response.params['response_reason_text'] || response.message
        raise Core::GatewayError.new(text)
      end

      response
    rescue ActiveMerchant::ConnectionError => error
      logger.error(I18n.t('spree.gateway_error') + "  #{error.inspect}")
      raise Core::GatewayError.new(I18n.t('spree.unable_to_connect_to_gateway'))
    end

    def amount_is_less_than_or_equal_to_allowed_amount
      if payment && amount > payment.credit_allowed
        errors.add(:amount, :greater_than_allowed)
      end
    end

    def update_order
      payment.order.updater.update
    end
  end
end
