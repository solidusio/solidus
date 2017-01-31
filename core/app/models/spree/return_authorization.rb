module Spree
  # Models the return of Inventory Units to a Stock Location for an Order.
  #
  class ReturnAuthorization < Spree::Base
    belongs_to :order, class_name: 'Spree::Order', inverse_of: :return_authorizations

    has_many :return_items, inverse_of: :return_authorization, dependent: :destroy
    has_many :inventory_units, through: :return_items, dependent: :nullify
    has_many :customer_returns, through: :return_items

    belongs_to :stock_location
    belongs_to :reason, class_name: 'Spree::ReturnReason', foreign_key: :return_reason_id

    before_create :generate_number

    accepts_nested_attributes_for :return_items, allow_destroy: true

    validates :order, presence: true
    validates :stock_location, presence: true
    validate :must_have_shipped_units, on: :create
    validate :no_previously_exchanged_inventory_units, on: :create

    state_machine initial: :authorized do
      before_transition to: :canceled, do: :cancel_return_items

      event :cancel do
        transition to: :canceled, from: :authorized, if: lambda { |return_authorization| return_authorization.can_cancel_return_items? }
      end
    end

    extend DisplayMoney
    money_methods :pre_tax_total, :amount

    self.whitelisted_ransackable_attributes = ['memo']

    def pre_tax_total
      return_items.map(&:pre_tax_amount).sum
    end

    def amount
      return_item.sum(:amount)
    end

    def currency
      order.currency
    end

    def refundable_amount
      order.discounted_item_amount + order.promo_total
    end

    def customer_returned_items?
      customer_returns.exists?
    end

    def can_cancel_return_items?
      return_items.any?(&:can_cancel?) || return_items.blank?
    end

    private

    def must_have_shipped_units
      if order.nil? || order.inventory_units.shipped.none?
        errors.add(:order, Spree.t(:has_no_shipped_units))
      end
    end

    def generate_number
      self.number ||= loop do
        random = "RA#{Array.new(9){ rand(9) }.join}"
        break random unless self.class.exists?(number: random)
      end
    end

    def no_previously_exchanged_inventory_units
      if return_items.map(&:inventory_unit).any?(&:exchange_requested?)
        errors.add(:base, Spree.t(:return_items_cannot_be_created_for_inventory_units_that_are_already_awaiting_exchange))
      end
    end

    def cancel_return_items
      return_items.each { |item| item.cancel! if item.can_cancel? }
    end
  end
end
