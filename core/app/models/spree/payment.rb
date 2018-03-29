# frozen_string_literal: true

module Spree
  # Manage and process a payment for an order, from a specific
  # source (e.g. `Spree::CreditCard`) using a specific payment method (e.g
  # `Solidus::Gateway::Braintree`).
  #
  class Payment < Spree::Base
    include Spree::Payment::Processing

    class InvalidStateChange < StandardError; end

    alias_attribute :identifier, :number
    deprecate :identifier, :identifier=, deprecator: Spree::Deprecation

    PENDING = 'pending'
    PROCESSING = 'processing'
    CHECKOUT = 'checkout'
    COMPLETED = 'completed'
    INVALID = 'invalid'
    VOID = 'void'
    FAILED = 'failed'
    DEFAULT_STATES = [PENDING, PROCESSING, CHECKOUT, COMPLETED, INVALID, VOID, FAILED]

    IDENTIFIER_CHARS    = (('A'..'Z').to_a + ('0'..'9').to_a - %w(0 1 I O)).freeze
    NON_RISKY_AVS_CODES = ['B', 'D', 'H', 'J', 'M', 'Q', 'T', 'V', 'X', 'Y'].freeze
    RISKY_AVS_CODES     = ['A', 'C', 'E', 'F', 'G', 'I', 'K', 'L', 'N', 'O', 'P', 'R', 'S', 'U', 'W', 'Z'].freeze

    belongs_to :order, class_name: 'Spree::Order', touch: true, inverse_of: :payments
    belongs_to :source, polymorphic: true
    belongs_to :payment_method, -> { with_deleted }, class_name: 'Spree::PaymentMethod', inverse_of: :payments

    has_many :offsets, -> { offset_payment }, class_name: "Spree::Payment", foreign_key: :source_id
    has_many :log_entries, as: :source
    has_many :state_changes, as: :stateful
    has_many :capture_events, class_name: 'Spree::PaymentCaptureEvent'
    has_many :refunds, inverse_of: :payment

    before_validation :validate_source, unless: :invalid?
    before_create :set_unique_identifier

    after_save :create_payment_profile, if: :profiles_supported?

    # update the order totals, etc.
    after_save :update_order

    after_create :create_eligible_credit_event

    # invalidate previously entered payments
    after_create :invalidate_old_payments

    attr_accessor :request_env

    validates :amount, numericality: true
    validates :source, presence: true, if: :source_required?
    validates :payment_method, presence: true
    validate :is_valid_state?

    default_scope -> { order(:created_at) }

    scope :from_credit_card, -> { where(source_type: 'Spree::CreditCard') }
    scope :with_state, ->(s) { where(state: s.to_s) }
    # "offset" is reserved by activerecord
    scope :offset_payment, -> { where("source_type = 'Spree::Payment' AND amount < 0 AND state = 'completed'") }

    scope :checkout, -> { with_state(CHECKOUT) }
    scope :completed, -> { with_state(COMPLETED) }
    scope :pending, -> { with_state(PENDING) }
    scope :processing, -> { with_state(PROCESSING) }
    scope :failed, -> { with_state(FAILED) }

    scope :risky, -> { where("avs_response IN (?) OR (cvv_response_code IS NOT NULL and cvv_response_code != 'M') OR state = 'failed'", RISKY_AVS_CODES) }
    scope :valid, -> { where.not(state: [FAILED, INVALID]) }

    scope :store_credits, -> { where(source_type: Spree::StoreCredit.to_s) }
    scope :not_store_credits, -> { where(arel_table[:source_type].not_eq(Spree::StoreCredit.to_s).or(arel_table[:source_type].eq(nil))) }

    def started_processing!
      started_processing || raise(InvalidStateChange)
    end

    def started_processing
      return false unless can_started_processing?
      change_state!(PROCESSING)
      true
    end

    def processing?
      state == PROCESSING
    end

    def can_started_processing?
      checkout? || pending? || completed? || processing?
    end

    def failure!
      failure || raise(InvalidStateChange)
    end

    def failure
      return false unless can_failure?
      change_state!(FAILED)
      true
    end

    def failed?
      state == FAILED
    end

    def can_failure?
      pending? || processing?
    end

    def pend!
      pend || raise(InvalidStateChange)
    end

    def pend
      return false unless can_pend?
      change_state!(PENDING)
      true
    end

    def pending?
      state == PENDING
    end

    def can_pend?
      checkout? || processing?
    end

    def complete!
      complete || raise(InvalidStateChange)
    end

    def complete
      return false unless can_complete?
      change_state!(COMPLETED)
      true
    end

    def completed?
      state == COMPLETED
    end

    def can_complete?
      processing? || pending? || checkout?
    end

    def void!
      void || raise(InvalidStateChange)
    end

    def void
      return false unless can_void?
      change_state!(VOID)
      true
    end

    def void?
      state == VOID
    end

    def can_void?
      pending? || processing? || completed? || checkout?
    end

    def invalidate!
      invalidate || raise(InvalidStateChange)
    end

    def invalidate
      return false unless can_invalidate?
      change_state!(INVALID)
      true
    end

    def invalid?
      state == INVALID
    end

    def can_invalidate?
      checkout?
    end

    def checkout?
      state == CHECKOUT
    end

    # @return [String] this payment's response code
    def transaction_id
      response_code
    end

    # @return [String] this payment's currency
    delegate :currency, to: :order

    # @return [Spree::Money] this amount of this payment as money object
    def money
      Spree::Money.new(amount, { currency: currency })
    end
    alias display_amount money

    # Sets the amount, parsing it based on i18n settings if it is a string.
    #
    # @param amount [BigDecimal, String] the desired new amount
    def amount=(amount)
      self[:amount] =
        case amount
        when String
          separator = I18n.t('number.currency.format.separator')
          number    = amount.delete("^0-9-#{separator}\.").tr(separator, '.')
          number.to_d if number.present?
        end || amount
    end

    # The total amount of the offsets (for old-style refunds) for this payment.
    #
    # @return [BigDecimal] the total amount of this payment's offsets
    def offsets_total
      offsets.pluck(:amount).sum
    end

    # The total amount this payment can be credited.
    #
    # @return [BigDecimal] the amount of this payment minus the offsets
    #   (old-style refunds) and refunds
    def credit_allowed
      amount - (offsets_total.abs + refunds.sum(:amount))
    end

    # @return [Boolean] true when this payment can be credited
    def can_credit?
      credit_allowed > 0
    end

    # @return [Boolean] true when this payment has been fully refunded
    def fully_refunded?
      refunds.map(&:amount).sum == amount
    end

    # @return [Array<String>] the actions available on this payment
    def actions
      sa = source_actions
      sa |= ["failure"] if processing?
      sa
    end

    # @return [Object] the source of ths payment
    def payment_source
      res = source.is_a?(Payment) ? source.source : source
      res || payment_method
    end

    # @return [Boolean] true when this payment is risky based on address
    def is_avs_risky?
      return false if avs_response.blank? || NON_RISKY_AVS_CODES.include?(avs_response)
      true
    end

    # @return [Boolean] true when this payment is risky based on cvv
    def is_cvv_risky?
      return false if cvv_response_code == "M"
      return false if cvv_response_code.nil?
      return false if cvv_response_message.present?
      true
    end

    # @return [BigDecimal] the total amount captured on this payment
    def captured_amount
      capture_events.sum(:amount)
    end

    # @return [BigDecimal] the total amount left uncaptured on this payment
    def uncaptured_amount
      amount - captured_amount
    end

    # @return [Boolean] true when the payment method exists and is a store credit payment method
    def store_credit?
      payment_method.try!(:store_credit?)
    end

    private

    def source_actions
      return [] unless payment_source && payment_source.respond_to?(:actions)
      payment_source.actions.select { |action| !payment_source.respond_to?("can_#{action}?") || payment_source.send("can_#{action}?", self) }
    end

    def validate_source
      if source && !source.valid?
        source.errors.each do |field, error|
          field_name = I18n.t("activerecord.attributes.#{source.class.to_s.underscore}.#{field}")
          errors.add(I18n.t(source.class.to_s.demodulize.underscore, scope: 'spree'), "#{field_name} #{error}")
        end
      end
      if errors.any?
        throw :abort
      end
    end

    def source_required?
      payment_method.present? && payment_method.source_required?
    end

    def profiles_supported?
      payment_method.respond_to?(:payment_profiles_supported?) && payment_method.payment_profiles_supported?
    end

    def create_payment_profile
      # Don't attempt to create on bad payments.
      return if [INVALID, FAILED].include?(state)
      # Payment profile cannot be created without source
      return unless source
      # Imported payments shouldn't create a payment profile.
      return if source.imported

      payment_method.create_profile(self)
    rescue ActiveMerchant::ConnectionError => e
      gateway_error e
    end

    def invalidate_old_payments
      if !store_credit? && ![INVALID, FAILED].include?(state)
        order.payments.select { |payment|
          payment.state == CHECKOUT && !payment.store_credit? && payment.id != id
        }.each(&:invalidate!)
      end
    end

    def update_order
      if order.completed? || completed? || void?
        order.recalculate
      end
    end

    # Necessary because some payment gateways will refuse payments with
    # duplicate IDs. We *were* using the Order number, but that's set once and
    # is unchanging. What we need is a unique identifier on a per-payment basis,
    # and this is it. Related to https://github.com/spree/spree/issues/1998.
    # See https://github.com/spree/spree/issues/1998#issuecomment-12869105
    def set_unique_identifier
      loop do
        self.number = generate_identifier
        break unless self.class.exists?(number: number)
      end
    end

    def generate_identifier
      Array.new(8){ IDENTIFIER_CHARS.sample }.join
    end

    def create_eligible_credit_event
      # When cancelling an order, a payment with the negative amount
      # of the payment total is created to refund the customer. That
      # payment has a source of itself (Spree::Payment) no matter the
      # type of payment getting refunded, hence the additional check
      # if the source is a store credit.
      if store_credit? && source.is_a?(Spree::StoreCredit)
        source.update_attributes!({
          action: Spree::StoreCredit::ELIGIBLE_ACTION,
          action_amount: amount,
          action_authorization_code: response_code
        })
      end
    end

    def store_state_change(previous_state, new_state)
      state_changes.create!(
        previous_state: previous_state,
        next_state:     new_state,
        name:           'payment'
      )
    end

    def change_state!(new_state)
      previous_state = state
      return if new_state == previous_state
      update!(state: new_state)
      store_state_change(previous_state, new_state)
    end

    def is_valid_state?
      unless DEFAULT_STATES.include?(state)
        errors.add(:state, "Invalid state")
      end
    end
  end
end
