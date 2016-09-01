require 'spree/core/validators/email'
require 'spree/order/checkout'

module Spree
  class Order < Spree::Base
    ORDER_NUMBER_LENGTH  = 9
    ORDER_NUMBER_LETTERS = false
    ORDER_NUMBER_PREFIX  = 'R'

    include Spree::Order::Checkout
    include Spree::Order::Payments

    class InsufficientStock < StandardError; end
    class CannotRebuildShipments < StandardError; end

    extend Spree::DisplayMoney
    money_methods :outstanding_balance, :item_total, :adjustment_total,
      :included_tax_total, :additional_tax_total, :tax_total,
      :shipment_total, :total, :order_total_after_store_credit, :total_available_store_credit
    alias :display_ship_total :display_shipment_total

    checkout_flow do
      go_to_state :address
      go_to_state :delivery
      go_to_state :payment, if: ->(order) { order.payment_required? }
      go_to_state :confirm
    end

    self.whitelisted_ransackable_associations = %w[shipments user promotions bill_address ship_address line_items]
    self.whitelisted_ransackable_attributes = %w[completed_at created_at email number state payment_state shipment_state total store_id]

    attr_reader :coupon_code
    attr_accessor :temporary_address, :temporary_credit_card

    belongs_to :user, class_name: Spree::UserClassHandle.new
    belongs_to :created_by, class_name: Spree::UserClassHandle.new
    belongs_to :approver, class_name: Spree::UserClassHandle.new
    belongs_to :canceler, class_name: Spree::UserClassHandle.new

    belongs_to :bill_address, foreign_key: :bill_address_id, class_name: 'Spree::Address'
    alias_attribute :billing_address, :bill_address

    belongs_to :ship_address, foreign_key: :ship_address_id, class_name: 'Spree::Address'
    alias_attribute :shipping_address, :ship_address
    alias_attribute :ship_total, :shipment_total

    belongs_to :store, class_name: 'Spree::Store'
    has_many :state_changes, as: :stateful
    has_many :line_items, -> { order(:created_at, :id) }, dependent: :destroy, inverse_of: :order
    has_many :payments, dependent: :destroy, inverse_of: :order
    has_many :return_authorizations, dependent: :destroy, inverse_of: :order
    has_many :reimbursements, inverse_of: :order
    has_many :adjustments, -> { order(:created_at) }, as: :adjustable, inverse_of: :adjustable, dependent: :destroy
    has_many :line_item_adjustments, through: :line_items, source: :adjustments
    has_many :shipment_adjustments, through: :shipments, source: :adjustments
    has_many :inventory_units, inverse_of: :order
    has_many :products, through: :variants
    has_many :variants, through: :line_items
    has_many :refunds, through: :payments
    has_many :all_adjustments,
             class_name: 'Spree::Adjustment',
             foreign_key: :order_id,
             dependent: :destroy,
             inverse_of: :order

    has_many :order_stock_locations, class_name: "Spree::OrderStockLocation"
    has_many :stock_locations, through: :order_stock_locations

    has_many :order_promotions, class_name: 'Spree::OrderPromotion'
    has_many :promotions, through: :order_promotions

    has_many :cartons, -> { distinct }, through: :inventory_units
    has_many :shipments, dependent: :destroy, inverse_of: :order do
      def states
        pluck(:state).uniq
      end
    end

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
    attr_accessor :use_billing

    before_create :create_token
    before_create :link_by_email

    validates :email, presence: true, if: :require_email
    validates :email, email: true, if: :require_email, allow_blank: true
    validates :number, presence: true, uniqueness: { allow_blank: true }
    validates :store_id, presence: true

    make_permalink field: :number

    delegate :update_totals, :persist_totals, to: :updater
    delegate :firstname, :lastname, to: :bill_address, prefix: true, allow_nil: true
    alias_method :billing_firstname, :bill_address_firstname
    alias_method :billing_lastname, :bill_address_lastname

    class_attribute :update_hooks
    self.update_hooks = Set.new

    class_attribute :line_item_comparison_hooks
    self.line_item_comparison_hooks = Set.new

    class << self
      def by_number(number)
        where(number: number)
      end
      deprecate :by_number, deprecator: Spree::Deprecation
    end

    scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
    scope :completed_between, ->(start_date, end_date) { where(completed_at: start_date..end_date) }

    scope :by_store, ->(store) { where(store_id: store.id) }

    # shows completed orders first, by their completed_at date, then uncompleted orders by their created_at
    scope :reverse_chronological, -> { order('spree_orders.completed_at IS NULL', completed_at: :desc, created_at: :desc) }
    scope :unreturned_exchange, -> { joins(:shipments).where('spree_orders.created_at > spree_shipments.created_at') }

    def self.by_customer(customer)
      joins(:user).where("#{Spree.user_class.table_name}.email" => customer)
    end

    def self.by_state(state)
      where(state: state)
    end

    def self.complete
      where.not(completed_at: nil)
    end

    def self.incomplete
      where(completed_at: nil)
    end

    # Use this method in other gems that wish to register their own custom logic
    # that should be called after Order#update
    def self.register_update_hook(hook)
      update_hooks.add(hook)
    end

    # Use this method in other gems that wish to register their own custom logic
    # that should be called when determining if two line items are equal.
    def self.register_line_item_comparison_hook(hook)
      line_item_comparison_hooks.add(hook)
    end

    # For compatiblity with Calculator::PriceSack
    def amount
      line_items.map(&:amount).sum
    end

    # Sum of all line item amounts pre-tax
    def pre_tax_item_amount
      line_items.to_a.sum(&:pre_tax_amount)
    end

    # Sum of all line item amounts after promotions, before added tax
    def discounted_item_amount
      line_items.to_a.sum(&:discounted_amount)
    end

    def currency
      self[:currency] || Spree::Config[:currency]
    end

    def shipping_discount
      shipment_adjustments.eligible.sum(:amount) * - 1
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
      total.to_f > 0.0
    end

    def confirmation_required?
      true
    end
    deprecate :confirmation_required?, deprecator: Spree::Deprecation

    def backordered?
      shipments.any?(&:backordered?)
    end

    # Returns the relevant zone (if any) to be used for taxation purposes.
    # Uses default tax zone unless there is a specific match
    def tax_zone
      @tax_zone ||= Zone.match(tax_address) || Zone.default_tax
    end

    # Returns the address for taxation based on configuration
    def tax_address
      if Spree::Config[:tax_using_ship_address]
        ship_address
      else
        bill_address
      end || store.default_cart_tax_location
    end

    def updater
      @updater ||= OrderUpdater.new(self)
    end

    def update!
      updater.update
    end

    def assign_billing_to_shipping_address
      self.ship_address = bill_address if bill_address
      true
    end

    def allow_cancel?
      return false unless completed? && state != 'canceled'
      shipment_state.nil? || %w{ready backorder pending}.include?(shipment_state)
    end

    def all_inventory_units_returned?
      inventory_units.all?(&:returned?)
    end

    def contents
      @contents ||= Spree::OrderContents.new(self)
    end

    def shipping
      @shipping ||= Spree::OrderShipping.new(self)
    end

    def cancellations
      @cancellations ||= Spree::OrderCancellations.new(self)
    end

    # Associates the specified user with the order.
    def associate_user!(user, override_email = true)
      self.user = user
      attrs_to_set = { user_id: user.try(:id) }
      attrs_to_set[:email] = user.try(:email) if override_email
      attrs_to_set[:created_by_id] = user.try(:id) if created_by.blank?

      if persisted?
        # immediately persist the changes we just made, but don't use save since we might have an invalid address associated
        self.class.unscoped.where(id: id).update_all(attrs_to_set)
      end

      assign_attributes(attrs_to_set)
    end

    def generate_order_number(options = {})
      options[:length]  ||= ORDER_NUMBER_LENGTH
      options[:letters] ||= ORDER_NUMBER_LETTERS
      options[:prefix]  ||= ORDER_NUMBER_PREFIX

      possible = (0..9).to_a
      possible += ('A'..'Z').to_a if options[:letters]

      self.number ||= loop do
        # Make a random number.
        random = "#{options[:prefix]}#{(0...options[:length]).map { possible.sample }.join}"
        # Use the random  number if no other order exists with it.
        if self.class.exists?(number: random)
          # If over half of all possible options are taken add another digit.
          options[:length] += 1 if self.class.count > (10**options[:length] / 2)
        else
          break random
        end
      end
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
    # params[:product_customizations]={...}
    #
    # and would provide:
    #
    # def product_customizations_match
    def line_item_options_match(line_item, options)
      return true unless options

      line_item_comparison_hooks.all? { |hook|
        send(hook, line_item, options)
      }
    end

    # Creates new tax charges if there are any applicable rates. If prices already
    # include taxes then price adjustments are created instead.
    def create_tax_charge!
      Spree::Tax::OrderAdjuster.new(self).adjust!
    end

    def outstanding_balance
      # If reimbursement has happened add it back to total to prevent balance_due payment state
      # See: https://github.com/spree/spree/issues/6229
      adjusted_payment_total = payment_total + refund_total

      if state == 'canceled'
        -1 * adjusted_payment_total
      else
        total - adjusted_payment_total
      end
    end

    def outstanding_balance?
      outstanding_balance != 0
    end

    def refund_total
      payments.flat_map(&:refunds).sum(&:amount)
    end

    def name
      if (address = bill_address || ship_address)
        "#{address.firstname} #{address.lastname}"
      end
    end

    def can_ship?
      complete? || resumed? || awaiting_return? || returned?
    end

    def credit_cards
      credit_card_ids = payments.from_credit_card.pluck(:source_id).uniq
      CreditCard.where(id: credit_card_ids)
    end

    def valid_credit_cards
      credit_card_ids = payments.from_credit_card.valid.pluck(:source_id).uniq
      CreditCard.where(id: credit_card_ids)
    end

    # Finalizes an in progress order after checkout is complete.
    # Called after transition to complete state when payments will have been processed
    def finalize!
      # lock all adjustments (coupon promotions, etc.)
      all_adjustments.each(&:finalize!)

      # update payment and shipment(s) states, and save
      updater.update_payment_state
      shipments.each do |shipment|
        shipment.update!(self)
        shipment.finalize!
      end

      updater.update_shipment_state
      save!
      updater.run_hooks

      touch :completed_at

      deliver_order_confirmation_email unless confirmation_delivered?
    end

    def fulfill!
      shipments.each { |shipment| shipment.update!(self) if shipment.persisted? }
      updater.update_shipment_state
      save!
    end

    def deliver_order_confirmation_email
      OrderMailer.confirm_email(self).deliver_later
      update_column(:confirmation_delivered, true)
    end

    # Helper methods for checkout steps
    def paid?
      %w(paid credit_owed).include?(payment_state)
    end

    def available_payment_methods
      @available_payment_methods ||= (
        PaymentMethod.available(:front_end, store: store) +
        PaymentMethod.available(:both, store: store)
      ).
      uniq.
      sort_by(&:position)
    end

    def insufficient_stock_lines
      line_items.select(&:insufficient_stock?)
    end

    ##
    # Check to see if any line item variants are soft, deleted.
    # If so add error and restart checkout.
    def ensure_line_item_variants_are_not_deleted
      if line_items.any? { |li| li.variant.paranoia_destroyed? }
        errors.add(:base, Spree.t(:deleted_variants_present))
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
      updater.update_item_count
      adjustments.destroy_all
      shipments.destroy_all

      update_totals
      persist_totals
    end

    def has_step?(step)
      checkout_steps.include?(step)
    end

    def state_changed(name)
      state = "#{name}_state"
      if persisted?
        old_state = send("#{state}_was")
        new_state = send(state)
        unless old_state == new_state
          state_changes.create(
            previous_state: old_state,
            next_state:     new_state,
            name:           name,
            user_id:        user_id
          )
        end
      end
    end

    def coupon_code=(code)
      @coupon_code = begin
                       code.strip.downcase
                     rescue
                       nil
                     end
    end

    def can_add_coupon?
      Spree::Promotion.order_activatable?(self)
    end

    def shipped?
      %w(partial shipped).include?(shipment_state)
    end

    def ensure_shipping_address
      unless ship_address && ship_address.valid?
        errors.add(:base, Spree.t(:ship_address_required)) && (return false)
      end
    end

    def create_proposed_shipments
      return shipments if unreturned_exchange?

      if completed?
        raise CannotRebuildShipments.new(Spree.t(:cannot_rebuild_shipments_order_completed))
      elsif shipments.any? { |s| !s.pending? }
        raise CannotRebuildShipments.new(Spree.t(:cannot_rebuild_shipments_shipments_not_pending))
      else
        shipments.destroy_all
        self.shipments = Spree::Config.stock.coordinator_class.new(self).shipments
      end
    end

    def apply_free_shipping_promotions
      Spree::PromotionHandler::FreeShipping.new(self).activate
      update!
    end

    # Clean shipments and make order back to address state
    #
    # At some point the might need to force the order to transition from address
    # to delivery again so that proper updated shipments are created.
    # e.g. customer goes back from payment step and changes order items
    def ensure_updated_shipments
      if !completed? && shipments.all?(&:pending?)
        shipments.destroy_all
        update_column(:shipment_total, 0)
        restart_checkout_flow
      end
    end

    def restart_checkout_flow
      return if state == 'cart'

      update_columns(
        state: 'cart',
        updated_at: Time.current
      )
      next! if line_items.size > 0
    end

    def refresh_shipment_rates
      shipments.map(&:refresh_rates)
    end

    def shipping_eq_billing_address?
      bill_address == ship_address
    end

    def set_shipments_cost
      shipments.each(&:update_amounts)
      updater.update_shipment_total
      persist_totals
    end

    def is_risky?
      payments.risky.count > 0
    end

    def canceled_by(user)
      transaction do
        cancel!
        update_columns(
          canceler_id: user.id,
          canceled_at: Time.current
        )
      end
    end

    def approved?
      !!approved_at
    end

    def can_approve?
      !approved?
    end

    def reload(options = nil)
      remove_instance_variable(:@tax_zone) if defined?(@tax_zone)
      super
    end

    def quantity
      line_items.sum(:quantity)
    end

    def has_non_reimbursement_related_refunds?
      refunds.non_reimbursement.exists? ||
        payments.offset_payment.exists? # how old versions of spree stored refunds
    end

    def token
      Spree::Deprecation.warn("Spree::Order#token is DEPRECATED, please use #guest_token instead.", caller)
      guest_token
    end

    # @deprecated Do not use this method. Behaviour is unreliable.
    def fully_discounted?
      adjustment_total + line_items.map(&:final_amount).sum == 0.0
    end
    alias_method :fully_discounted, :fully_discounted?
    deprecate :fully_discounted, deprecator: Spree::Deprecation

    def unreturned_exchange?
      # created_at - 1 is a hack to ensure that this doesn't blow up on MySQL,
      # records loaded from the DB on MySQL will have a precision of 1 second,
      # but records in memory may still have miliseconds on them, causing this
      # to be true where it shouldn't be.
      #
      # FIXME: find a better way to determine if an order is an unreturned
      # exchange
      shipment = shipments.first
      shipment.present? ? (shipment.created_at < created_at - 1) : false
    end

    def tax_total
      additional_tax_total + included_tax_total
    end

    def add_store_credit_payments
      return if user.nil?
      return if payments.store_credits.checkout.empty? && user.total_available_store_credit.zero?

      payments.store_credits.checkout.each(&:invalidate!)

      # this can happen when multiple payments are present, auto_capture is
      # turned off, and one of the payments fails when the user tries to
      # complete the order, which sends the order back to the 'payment' state.
      authorized_total = payments.pending.sum(:amount)

      remaining_total = outstanding_balance - authorized_total

      if user.store_credits.any?
        payment_method = Spree::PaymentMethod::StoreCredit.first

        user.store_credits.order_by_priority.each do |credit|
          break if remaining_total.zero?
          next if credit.amount_remaining.zero?

          amount_to_take = [credit.amount_remaining, remaining_total].min
          payments.create!(source: credit,
                           payment_method: payment_method,
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
        other_payments.first.update_attributes!(amount: remaining_total)
      end

      payments.reset

      if payments.where(state: %w(checkout pending)).sum(:amount) != total
        errors.add(:base, Spree.t("store_credit.errors.unable_to_fund")) && (return false)
      end
    end

    def covered_by_store_credit?
      return false unless user
      user.total_available_store_credit >= total
    end
    alias_method :covered_by_store_credit, :covered_by_store_credit?

    def total_available_store_credit
      return 0.0 unless user
      user.total_available_store_credit
    end

    def order_total_after_store_credit
      total - total_applicable_store_credit
    end

    def total_applicable_store_credit
      if confirm? || complete?
        payments.store_credits.valid.sum(:amount)
      else
        [total, (user.try(:total_available_store_credit) || 0.0)].min
      end
    end

    def display_total_applicable_store_credit
      Spree::Money.new(-total_applicable_store_credit, { currency: currency })
    end

    def display_store_credit_remaining_after_capture
      Spree::Money.new(total_available_store_credit - total_applicable_store_credit, { currency: currency })
    end

    private

    def associate_store
      self.store ||= Spree::Store.default
    end

    def link_by_email
      self.email = user.email if user
    end

    # Determine if email is required (we don't want validation errors before we hit the checkout)
    def require_email
      true unless new_record? || ['cart', 'address'].include?(state)
    end

    def ensure_inventory_units
      if has_step?("delivery")
        inventory_validator = Spree::Stock::InventoryValidator.new

        errors = line_items.map { |line_item| inventory_validator.validate(line_item) }.compact
        raise InsufficientStock if errors.any?
      end
    end

    def ensure_promotions_eligible
      updater.update_adjustment_total
      if promo_total_changed?
        restart_checkout_flow
        errors.add(:base, Spree.t(:promotion_total_changed_before_complete))
      end
      errors.empty?
    end

    def validate_line_item_availability
      availability_validator = Spree::Stock::AvailabilityValidator.new
      raise InsufficientStock unless line_items.all? { |line_item| availability_validator.validate(line_item) }
    end

    def ensure_line_items_present
      unless line_items.present?
        errors.add(:base, Spree.t(:there_are_no_items_for_this_order)) && (return false)
      end
    end

    def ensure_available_shipping_rates
      if shipments.empty? || shipments.any? { |shipment| shipment.shipping_rates.blank? }
        # After this point, order redirects back to 'address' state and asks user to pick a proper address
        # Therefore, shipments are not necessary at this point.
        shipments.destroy_all
        errors.add(:base, Spree.t(:items_cannot_be_shipped)) && (return false)
      end
    end

    def after_cancel
      shipments.each(&:cancel!)
      payments.completed.each(&:cancel!)
      payments.store_credits.pending.each(&:void_transaction!)

      send_cancel_email
      update!
    end

    def send_cancel_email
      OrderMailer.cancel_email(self).deliver_later
    end

    def after_resume
      shipments.each(&:resume!)
    end

    def use_billing?
      use_billing.in?([true, 'true', '1'])
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
