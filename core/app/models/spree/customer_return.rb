# frozen_string_literal: true

module Spree
  class CustomerReturn < Spree::Base
    include Metadata

    belongs_to :stock_location, optional: true

    has_many :return_items, inverse_of: :customer_return
    has_many :return_authorizations, through: :return_items
    has_many :reimbursements, inverse_of: :customer_return

    after_create :process_return!
    before_create :generate_number

    validates :return_items, presence: true
    validates :stock_location, presence: true
    validate :return_items_belong_to_same_order

    accepts_nested_attributes_for :return_items

    self.allowed_ransackable_attributes = ["number"]

    extend DisplayMoney
    money_methods :total, :total_excluding_vat, :amount

    delegate :currency, to: :order
    delegate :id, to: :order, prefix: true, allow_nil: true

    def total
      return_items.sum(&:total)
    end

    def total_excluding_vat
      return_items.sum(&:total_excluding_vat)
    end

    def amount
      return_items.sum(:amount)
    end

    # Temporarily tie a customer_return to one order
    def order
      return nil if return_items.blank?

      return_items.first.inventory_unit&.order
    end

    def fully_reimbursed?
      completely_decided? && return_items.accepted.includes(:reimbursement).all? { |return_item| return_item.reimbursement.try(:reimbursed?) }
    end

    def completely_decided?
      !return_items.undecided.exists?
    end

    def process_return!
      order.return! if order.can_return?
    end

    private

    def generate_number
      self.number ||= loop do
        random = "CR#{Array.new(9) { rand(9) }.join}"
        break random unless self.class.exists?(number: random)
      end
    end

    def return_items_belong_to_same_order
      if return_items.reject { |return_item| return_item.inventory_unit&.order_id == order_id }.any?
        errors.add(:base, I18n.t("spree.return_items_cannot_be_associated_with_multiple_orders"))
      end
    end

    def inventory_units
      return_items.flat_map(&:inventory_unit)
    end
  end
end
