# frozen_string_literal: true

module Spree
  # The customers cart until completed, then acts as permanent record of the transaction.
  #
  # `Spree::Order` is the heart of the Solidus system, as it acts as the customer's
  # cart as they shop. Once an order is complete, it serves as the
  # permanent record of their purchase. It has many responsibilities:
  #
  # * Records and validates attributes like `total` and relationships like
  # `Spree::LineItem` as an ActiveRecord model.
  #
  # * Implements a customizable state machine to manage the lifecycle of an order.
  #
  # * Implements business logic to provide a single interface for quesitons like
  # `checkout_allowed?` or `payment_required?`.
  #
  #  * Implements an interface for mutating the order with methods like
  # `empty!` and `fulfill!`.
  #
  class Order < Spree::Base
    ORDER_NUMBER_LENGTH  = 9
    ORDER_NUMBER_LETTERS = false
    ORDER_NUMBER_PREFIX  = 'R'

    include ::Spree::Config.state_machines.order

    include Spree::Order::Payments
    include Metadata

    class InsufficientStock < StandardError
      attr_reader :items

      def initialize(message = nil, items: {})
        @items = items
        super message
      end
    end
    class CannotRebuildShipments < StandardError; end

    extend Spree::DisplayMoney
    money_methods(
      :outstanding_balance,
      :item_total,
      :adjustment_total,
      :included_tax_total,
      :additional_tax_total,
      :tax_total,
      :shipment_total,
      :total,
      :order_total_after_store_credit,
      :total_available_store_credit,
      :item_total_before_tax,
      :shipment_total_before_tax,
      :item_total_excluding_vat,
      :promo_total
    )
    alias :display_ship_total :display_shipment_total

    checkout_flow do
      go_to_state :address
      go_to_state :delivery
      go_to_state :payment, if: ->(order) { order.payment_required? }
      go_to_state :confirm
    end

    self.allowed_ransackable_associations = %w[shipments user bill_address ship_address line_items]
    self.allowed_ransackable_attributes = %w[completed_at created_at email number state payment_state shipment_state total store_id]

    attr_reader :coupon_code
    attr_accessor :temporary_address

    attr_accessor :temporary_payment_source

    # Customer info
    belongs_to :user, class_name: Spree::UserClassHandle.new, optional: true

    belongs_to :bill_address, foreign_key: :bill_address_id, class_name: 'Spree::Address', optional: true
    alias_method :billing_address, :bill_address
    alias_method :billing_address=, :bill_address=

    belongs_to :ship_address, foreign_key: :ship_address_id, class_name: 'Spree::Address', optional: true
    alias_method :shipping_address, :ship_address
    alias_method :shipping_address=, :ship_address=

    alias_attribute :ship_total, :shipment_total

    belongs_to :store, class_name: 'Spree::Store', optional: true

    # Items
    has_many :line_items, -> { order(:created_at, :id) }, dependent: :destroy, inverse_of: :order
    has_many :variants, through: :line_items
    has_many :products, through: :variants

    # Shipping
    has_many :shipments, dependent: :destroy, inverse_of: :order do
      def states
        pluck(:state).uniq
      end
    end
    has_many :inventory_units, through: :shipments
    has_many :cartons, -> { distinct }, through: :inventory_units

    # Adjustments and promotions
    has_many :adjustments, -> { order(:created_at) }, as: :adjustable, inverse_of: :adjustable, dependent: :destroy, autosave: true
    has_many :line_item_adjustments, through: :line_items, source: :adjustments
    has_many :shipment_adjustments, through: :shipments, source: :adjustments
    has_many :all_adjustments,
             class_name: 'Spree::Adjustment',
             foreign_key: :order_id,
             dependent: :destroy,
             inverse_of: :order

    # Payments
    has_many :payments, dependent: :destroy, inverse_of: :order
    has_many :valid_store_credit_payments, -> { store_credits.valid }, inverse_of: :order, class_name: 'Spree::Payment', foreign_key: :order_id

    # Returns
    has_many :return_authorizations, dependent: :destroy, inverse_of: :order
    has_many :return_items, through: :inventory_units
    has_many :customer_returns, -> { distinct }, through: :return_items
    has_many :reimbursements, inverse_of: :order
    has_many :refunds, through: :payments

    # Logging
    has_many :state_changes, as: :stateful
    belongs_to :created_by, class_name: Spree::UserClassHandle.new, optional: true
    belongs_to :approver, class_name: Spree::UserClassHandle.new, optional: true
    belongs_to :canceler, class_name: Spree::UserClassHandle.new, optional: true

    accepts_nested_attributes_for :line_items
    accepts_nested_attributes_for :bill_address
    accepts_nested_attributes_for :ship_address
    accepts_nested_attributes_for :payments
    accepts_nested_attributes_for :shipments

    # Needs to happen before save_permalink is called
    before_validation :associate_store
    before_validation :set_currency
    before_validation :generate_order_number, on: :create
    before_validation :assign_billing_to_shipping_address, if: :use_billing?
    before_validation :assign_shipping_to_billing_address, if: :use_shipping?
    attr_accessor :use_billing
    attr_accessor :use_shipping

    before_create :create_token
    before_create :link_by_email

    validates :email, presence: true, if: :email_required?
    validates :email, 'spree/email' => true, allow_blank: true
    validates :guest_token, presence: { allow_nil: true }
    validates :number, presence: true, uniqueness: { allow_blank: true, case_sensitive: true }
    validates :store_id, presence: true

    def self.find_by_param(value)
      find_by number: value
    end

    def self.find_by_param!(value)
      find_by! number: value
    end

    delegate :recalculate, to: :recalculator

    delegate :name, to: :bill_address, prefix: true, allow_nil: true
    alias_method :billing_name, :bill_address_name

    delegate :line_item_comparison_hooks, to: :class
    class << self
      def line_item_comparison_hooks=(value)
        Spree::Config.line_item_comparison_hooks = value.to_a
      end
      line_item_hooks_deprecation_msg = "Use Spree::Config.line_item_comparison_hooks instead."
      deprecate :line_item_comparison_hooks= => line_item_hooks_deprecation_msg, :deprecator => Spree.deprecator

      def line_item_comparison_hooks
        Spree::Config.line_item_comparison_hooks
      end
      deprecate line_item_comparison_hooks: line_item_hooks_deprecation_msg, deprecator: Spree.deprecator

      def register_line_item_comparison_hook(hook)
        Spree::Config.line_item_comparison_hooks << hook
      end
      deprecate register_line_item_comparison_hook: line_item_hooks_deprecation_msg, deprecator: Spree.deprecator
    end

    scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
    scope :completed_between, ->(start_date, end_date) { where(completed_at: start_date..end_date) }

    scope :by_store, ->(store) { where(store_id: store.id) }

    # shows completed orders first, by their completed_at date, then uncompleted orders by their created_at
    scope :reverse_chronological, -> { order(Arel.sql('spree_orders.completed_at IS NULL'), completed_at: :desc, created_at: :desc) }

    def self.by_customer(customer)
      joins(:user).where("#{Spree.user_class.table_name}.email" => customer)
    end

    def self.by_state(state)
      where(state:)
    end

    def self.complete
      where.not(completed_at: nil)
    end

    def self.incomplete
      where(completed_at: nil)
    end

    def self.canceled
      where(state: 'canceled')
    end

    def self.not_canceled
      where.not(state: 'canceled')
    end

    # For compatiblity with Calculator::PriceSack
    def amount
      line_items.sum(&:amount)
    end

    def item_total_before_tax
      line_items.to_a.sum(&:total_before_tax)
    end

    def shipment_total_before_tax
      shipments.to_a.sum(&:total_before_tax)
    end

    # Sum of all line item amounts pre-tax
    def item_total_excluding_vat
      line_items.to_a.sum(&:total_excluding_vat)
    end

    def currency
      self[:currency] || Spree::Config[:currency]
    end

    def shipping_discount
      shipment_adjustments.credit.sum(:amount) * - 1
    end

    def to_param
      number
    end

    def completed?
      completed_at.present?
    end

    # Indicates whether or not the user is allowed to proceed to checkout.
    # Currently this is implemented as a check for whether or not there is at
    # least one LineItem in the Order.  Feel free to override this logic in your
    # own application if you require additional steps before allowing a checkout.
    def checkout_allowed?
      line_items.count > 0
    end

    # Is this a free order in which case the payment step should be skipped
    def payment_required?
      total > 0
    end

    def backordered?
      shipments.any?(&:backordered?)
    end

    # Returns the address for taxation based on configuration
    def tax_address
      if Spree::Config[:tax_using_ship_address]
        ship_address
      else
        bill_address
      end || store&.default_cart_tax_location
    end

    def recalculator
      @recalculator ||= Spree::Config.order_recalculator_class.new(self)
    end
    alias_method :updater, :recalculator
    deprecate updater: :recalculator, deprecator: Spree.deprecator

    def assign_billing_to_shipping_address
      self.ship_address = bill_address if bill_address
      true
    end

    def assign_shipping_to_billing_address
      self.bill_address = ship_address if ship_address
      true
    end

    def allow_cancel?
      return false unless completed? && state != 'canceled'
      shipment_state.nil? || %w{ready backorder pending}.include?(shipment_state)
    end

    def all_inventory_units_returned?
      # Inventory units are transitioned to the "return" state through CustomerReturn and
      # ReturnItem instead of using Order#inventory_units, thus making the latter method
      # potentially return stale data. This situation requires to *reload* `inventory_units`
      # in order to pick-up the latest changes and make the check on `returned?` reliable.
      inventory_units.reload.all?(&:returned?)
    end

    def contents
      @contents ||= Spree::Config.order_contents_class.new(self)
    end

    def shipping
      @shipping ||= Spree::Config.order_shipping_class.new(self)
    end

    def cancellations
      @cancellations ||= Spree::Config.order_cancellations_class.new(self)
    end

    # Associates the specified user with the order.
    def associate_user!(user, override_email = true)
      self.user = user
      attrs_to_set = { user_id: user.try(:id) }
      attrs_to_set[:email] = user.try(:email) if override_email
      attrs_to_set[:created_by_id] = user.try(:id) if created_by.blank?

      if persisted?
        # immediately persist the changes we just made, but don't use save since we might have an invalid address associated
        self.class.unscoped.where(id:).update_all(attrs_to_set)
      end

      assign_attributes(attrs_to_set)
    end

    def generate_order_number
      self.number ||= Spree::Config.order_number_generator.generate
    end

    def shipped_shipments
      shipments.shipped
    end

    def contains?(variant, options = {})
      find_line_item_by_variant(variant, options).present?
    end

    def quantity_of(variant, options = {})
      line_item = find_line_item_by_variant(variant, options)
      line_item ? line_item.quantity : 0
    end

    def find_line_item_by_variant(variant, options = {})
      line_items.detect { |line_item|
                    line_item.variant_id == variant.id &&
                      line_item_options_match(line_item, options)
      }
    end

    # This method enables extensions to participate in the
    # "Are these line items equal" decision.
    #
    # When adding to cart, an extension would send something like:
    # params[:product_customizations]=...
    #
    # and would provide:
    #
    # def product_customizations_match
    def line_item_options_match(line_item, options)
      return true unless options

      Spree::Config.line_item_comparison_hooks.all? { |hook|
        send(hook, line_item, options)
      }
    end

    def reimbursement_total
      reimbursements.sum(:total)
    end

    def outstanding_balance
      # If reimbursement has happened add it back to total to prevent balance_due payment state
      # See: https://github.com/spree/spree/issues/6229

      if state == 'canceled'
        -1 * payment_total
      else
        total - reimbursement_total - payment_total
      end
    end

    def outstanding_balance?
      outstanding_balance != 0
    end

    def refund_total
      refunds.sum(&:amount)
    end

    def name
      if (address = bill_address || ship_address)
        address.name
      end
    end

    def can_ship?
      complete? || resumed? || awaiting_return? || returned?
    end

    def credit_cards
      credit_card_ids = payments.from_credit_card.pluck(:source_id).uniq
      Spree::CreditCard.where(id: credit_card_ids)
    end

    def valid_credit_cards
      credit_card_ids = payments.from_credit_card.valid.pluck(:source_id).uniq
      Spree::CreditCard.where(id: credit_card_ids)
    end

    def fulfill!
      shipments.each { |shipment| shipment.update_state if shipment.persisted? }
      recalculator.recalculate_shipment_state
      save!
    end

    # Helper methods for checkout steps
    def paid?
      %w(paid credit_owed).include?(payment_state)
    end

    def available_payment_methods
      @available_payment_methods ||= Spree::PaymentMethod
        .active
        .available_to_store(store)
        .available_to_users
        .order(:position)
    end

    def insufficient_stock_lines
      line_items.select(&:insufficient_stock?)
    end

    ##
    # Check to see if any line item variants are soft, deleted.
    # If so add error and restart checkout.
    def ensure_line_item_variants_are_not_deleted
      if line_items.any? { |li| li.variant.discarded? }
        errors.add(:base, I18n.t('spree.deleted_variants_present'))
        restart_checkout_flow
        false
      else
        true
      end
    end

    def merge!(*args)
      Spree::Config.order_merger_class.new(self).merge!(*args)
    end

    def empty!
      line_items.destroy_all
      adjustments.destroy_all
      shipments.destroy_all
      Spree::Bus.publish :order_emptied, order: self

      recalculate
    end

    def coupon_code=(code)
      @coupon_code = begin
                       code.strip.downcase
                     rescue StandardError
                       nil
                     end
    end

    def can_add_coupon?
      Spree::Config.promotions.coupon_code_handler_class.new(self).can_apply?
    end

    def shipped?
      %w(partial shipped).include?(shipment_state)
    end

    def ensure_shipping_address
      unless ship_address && ship_address.valid?
        errors.add(:base, I18n.t('spree.ship_address_required')) && (return false)
      end
    end

    def ensure_billing_address
      return unless billing_address_required?
      return if bill_address&.valid?

      errors.add(:base, I18n.t('spree.bill_address_required'))
      false
    end

    def billing_address_required?
      Spree::Config.billing_address_required
    end

    def create_proposed_shipments
      if completed?
        raise CannotRebuildShipments.new(I18n.t('spree.cannot_rebuild_shipments_order_completed'))
      elsif shipments.any? { |shipment| !shipment.pending? }
        raise CannotRebuildShipments.new(I18n.t('spree.cannot_rebuild_shipments_shipments_not_pending'))
      else
        shipments.destroy_all
        shipments.push(*Spree::Config.stock.coordinator_class.new(self).shipments)
      end
    end

    def create_shipments_for_line_item(line_item)
      units = Spree::Config.stock.inventory_unit_builder_class.new(self).missing_units_for_line_item(line_item)

      Spree::Config.stock.coordinator_class.new(self, units).shipments.each do |shipment|
        shipments << shipment
      end
    end

    # Clean shipments and make order back to address state (or to whatever state
    # is set by restart_checkout_flow in case of state machine modifications)
    def check_shipments_and_restart_checkout
      if !completed? && shipments.all?(&:pending?)
        shipments.destroy_all
        update_column(:shipment_total, 0)
        restart_checkout_flow
      end
    end

    alias_method :ensure_updated_shipments, :check_shipments_and_restart_checkout
    deprecate ensure_updated_shipments: :check_shipments_and_restart_checkout, deprecator: Spree.deprecator

    def restart_checkout_flow
      return if state == 'cart'

      update_columns(
        state: 'cart',
        updated_at: Time.current
      )
      self.next if line_items.any?
    end

    def refresh_shipment_rates
      shipments.map(&:refresh_rates)
    end

    def shipping_eq_billing_address?
      bill_address == ship_address
    end

    def is_risky?
      payments.risky.count > 0
    end

    def canceled_by(user)
      transaction do
        cancel!
        update_column(:canceler_id, user.id)
      end
    end

    def approved?
      !!approved_at
    end

    def can_approve?
      !approved?
    end

    def quantity
      line_items.sum(:quantity)
    end

    def has_non_reimbursement_related_refunds?
      refunds.non_reimbursement.exists?
    end

    def tax_total
      additional_tax_total + included_tax_total
    end

    def add_store_credit_payments
      return if user.nil?
      return if payments.store_credits.checkout.empty? && user.available_store_credit_total(currency:).zero?

      payments.store_credits.checkout.each(&:invalidate!)

      # this can happen when multiple payments are present, auto_capture is
      # turned off, and one of the payments fails when the user tries to
      # complete the order, which sends the order back to the 'payment' state.
      authorized_total = payments.pending.sum(:amount)

      remaining_total = outstanding_balance - authorized_total

      matching_store_credits = user.store_credits.where(currency:)

      if matching_store_credits.any?
        payment_method = Spree::PaymentMethod::StoreCredit.first
        sorter = Spree::Config.store_credit_prioritizer_class.new(matching_store_credits, self)

        sorter.call.each do |credit|
          break if remaining_total.zero?
          next if credit.amount_remaining.zero?

          amount_to_take = [credit.amount_remaining, remaining_total].min
          payments.create!(source: credit,
                           payment_method:,
                           amount: amount_to_take,
                           state: 'checkout',
                           response_code: credit.generate_authorization_code)
          remaining_total -= amount_to_take
        end
      end

      other_payments = payments.checkout.not_store_credits
      if remaining_total.zero?
        other_payments.each(&:invalidate!)
      elsif other_payments.size == 1
        other_payments.first.update!(amount: remaining_total)
      end

      payments.reset

      if payments.where(state: %w(checkout pending completed)).sum(:amount) != total
        errors.add(:base, I18n.t('spree.store_credit.errors.unable_to_fund')) && (return false)
      end
    end

    def covered_by_store_credit?
      return false unless user
      user.available_store_credit_total(currency:) >= total
    end
    alias_method :covered_by_store_credit, :covered_by_store_credit?

    def total_available_store_credit
      return 0.0 unless user
      user.available_store_credit_total(currency:)
    end

    def order_total_after_store_credit
      total - total_applicable_store_credit
    end

    def total_applicable_store_credit
      if can_complete? || complete?
        valid_store_credit_payments.to_a.sum(&:amount)
      else
        [total, user.try(:available_store_credit_total, currency:) || 0.0].min
      end
    end

    def display_total_applicable_store_credit
      Spree::Money.new(-total_applicable_store_credit, { currency: })
    end

    def display_store_credit_remaining_after_capture
      Spree::Money.new(total_available_store_credit - total_applicable_store_credit, { currency: })
    end

    def bill_address_attributes=(attributes)
      self.bill_address = Spree::Address.immutable_merge(bill_address, attributes)
    end

    def ship_address_attributes=(attributes)
      self.ship_address = Spree::Address.immutable_merge(ship_address, attributes)
    end

    # Assigns a default bill_address and ship_address to the order based on the
    # associated user's bill_address and ship_address.
    # @note This doesn't persist the change bill_address or ship_address
    def assign_default_user_addresses
      if user
        bill_address = user.bill_address
        ship_address = user.ship_address
        # this is one of 2 places still using User#bill_address
        self.bill_address ||= bill_address if bill_address.try!(:valid?)
        # Skip setting ship address if order doesn't have a delivery checkout step
        # to avoid triggering validations on shipping address
        self.ship_address ||= ship_address if ship_address.try!(:valid?) && checkout_steps.include?("delivery")
      end
    end

    def persist_user_address!
      if !temporary_address && user && user.respond_to?(:persist_order_address) && bill_address_id
        user.persist_order_address(self)
      end
    end

    def add_payment_sources_to_wallet
      Spree::Config.
        add_payment_sources_to_wallet_class.new(self).
        add_to_wallet
    end

    def add_default_payment_from_wallet
      builder = Spree::Config.default_payment_builder_class.new(self)

      if payment = builder.build
        payments << payment

        if bill_address.nil?
          # this is one of 2 places still using User#bill_address
          self.bill_address = payment.source.try(:address) ||
                              user.bill_address
        end
      end
    end

    def record_ip_address(ip_address)
      if new_record?
        self.last_ip_address = ip_address
      elsif last_ip_address != ip_address
        update_column(:last_ip_address, ip_address)
      end
    end

    def payments_attributes=(attributes)
      validate_payments_attributes(attributes)
      super(attributes)
    end

    def validate_payments_attributes(attributes)
      attributes = Array(attributes)

      attributes.each do |payment_attributes|
        payment_method_id = payment_attributes[:payment_method_id]

        # raise RecordNotFound unless it is an allowed payment method
        available_payment_methods.find(payment_method_id) if payment_method_id
      end
    end

    private

    def process_payments_before_complete
      return if !payment_required?

      if payments.valid.empty?
        errors.add(:base, I18n.t('spree.no_payment_found'))
        return false
      end

      if process_payments!
        true
      else
        saved_errors = errors[:base]
        payment_failed!
        saved_errors.each { |error| errors.add(:base, error) }
        false
      end
    end

    # Finalizes an in progress order after checkout is complete.
    # Called after transition to complete state when payments will have been processed
    def finalize
      # lock all adjustments (coupon promotions, etc.)
      all_adjustments.each(&:finalize!)

      # update payment and shipment(s) states, and save
      recalculator.update_payment_state
      shipments.each do |shipment|
        shipment.update_state
        shipment.finalize!
      end

      recalculator.recalculate_shipment_state
      save!

      touch :completed_at

      Spree::Bus.publish :order_finalized, order: self
    end

    def associate_store
      self.store ||= Spree::Store.default
    end

    def link_by_email
      self.email = user.email if user
    end

    # Determine if the email is required for this order
    #
    # We don't require email for orders in the cart state or address state because those states
    # precede the entry of an email address.
    #
    # @return [Boolean] true if the email is required
    # @note This method was called require_email before.
    def email_required?
      true unless new_record? || ['cart', 'address'].include?(state)
    end

    def ensure_inventory_units
      if has_checkout_step?("delivery")
        inventory_validator = Spree::Config.stock.inventory_validator_class.new

        errors = line_items.map { |line_item|
          inventory_validator.validate(line_item)
        }.compact

        raise InsufficientStock if errors.any?
      end
    end

    def ensure_promotions_eligible
      Spree::Config.promotions.order_adjuster_class.new(self).call

      if promo_total_changed?
        restart_checkout_flow
        recalculate
        errors.add(:base, I18n.t('spree.promotion_total_changed_before_complete'))
      end
      errors.empty?
    end

    def validate_line_item_availability
      availability_validator = Spree::Config.stock.availability_validator_class.new

      # NOTE: This code assumes that the availability validator will return
      # true for success and false for failure. This is not normally the
      # behaviour of validators, as the framework only cares about the
      # population of the errors, not the return value of the validate method.
      raise InsufficientStock unless line_items.all? { |line_item|
        availability_validator.validate(line_item)
      }
    end

    def ensure_line_items_present
      unless line_items.present?
        errors.add(:base, I18n.t('spree.there_are_no_items_for_this_order')) && (return false)
      end
    end

    def ensure_available_shipping_rates
      if shipments.empty? || shipments.any? { |shipment| shipment.shipping_rates.blank? }
        # After this point, order redirects back to 'address' state and asks user to pick a proper address
        # Therefore, shipments are not necessary at this point.
        shipments.destroy_all
        errors.add(:base, I18n.t('spree.items_cannot_be_shipped')) && (return false)
      end
    end

    def after_cancel
      cancel_shipments!
      cancel_payments!

      update_column(:canceled_at, Time.current)
      recalculate

      Spree::Bus.publish :order_canceled, order: self
    end

    def cancel_shipments!
      shipments.each(&:cancel!)
    end

    def cancel_payments!
      payments.each do |payment|
        next if payment.fully_refunded?
        next unless payment.pending? || payment.completed?

        payment.cancel!
      end
    end

    def after_resume
      shipments.each(&:resume!)
    end

    def use_billing?
      use_billing.in?([true, 'true', '1'])
    end

    def use_shipping?
      use_shipping.in?([true, 'true', '1'])
    end

    def set_currency
      self.currency = Spree::Config[:currency] if self[:currency].nil?
    end

    def create_token
      self.guest_token ||= loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless self.class.exists?(guest_token: random_token)
      end
    end
  end
end
