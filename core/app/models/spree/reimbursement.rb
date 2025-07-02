# frozen_string_literal: true

module Spree
  class Reimbursement < Spree::Base
    class IncompleteReimbursementError < StandardError; end

    belongs_to :order, inverse_of: :reimbursements, optional: true
    belongs_to :customer_return, inverse_of: :reimbursements, touch: true, optional: true

    has_many :refunds,
      inverse_of: :reimbursement,
      dependent: :restrict_with_error
    has_many :credits,
      inverse_of: :reimbursement,
      class_name: 'Spree::Reimbursement::Credit',
      dependent: :restrict_with_error

    has_many :return_items,
      inverse_of: :reimbursement,
      dependent: :restrict_with_error

    validates :order, presence: true
    validate :validate_return_items_belong_to_same_order

    accepts_nested_attributes_for :return_items, allow_destroy: true

    before_create :generate_number
    before_create :calculate_total

    scope :reimbursed, -> { where(reimbursement_status: 'reimbursed') }

    # The reimbursement_tax_calculator property should be set to an object that responds to "call"
    # and accepts a reimbursement object. Invoking "call" should update the tax fields on the
    # associated ReturnItems.
    # This allows a store to easily integrate with third party tax services.
    class_attribute :reimbursement_tax_calculator
    self.reimbursement_tax_calculator = ReimbursementTaxCalculator
    # A separate attribute here allows you to use a more performant calculator for estimates
    # and a different one (e.g. one that hits a 3rd party API) for the final caluclations.
    class_attribute :reimbursement_simulator_tax_calculator
    self.reimbursement_simulator_tax_calculator = ReimbursementTaxCalculator

    # The reimbursement_models property should contain an array of all models that provide
    # reimbursements.
    # This allows a store to incorporate custom reimbursement methods that Spree doesn't know about.
    # Each model must implement a "total_amount_reimbursed_for" method.
    # Example:
    #   Refund.total_amount_reimbursed_for(reimbursement)
    # See the `reimbursement_generator` property regarding the generation of custom reimbursements.
    class_attribute :reimbursement_models
    self.reimbursement_models = [Spree::Refund, Spree::Reimbursement::Credit]

    # The reimbursement_performer property should be set to an object that responds to the following methods:
    # - #perform
    # - #simulate
    # see ReimbursementPerformer for details.
    # This allows a store to customize their reimbursement methods and logic.
    class_attribute :reimbursement_performer
    self.reimbursement_performer = ReimbursementPerformer

    include ::Spree::Config.state_machines.reimbursement

    class << self
      def build_from_customer_return(customer_return)
        order = customer_return.order
        order.reimbursements.build({
          customer_return:,
          return_items: customer_return.return_items.accepted.not_reimbursed
        })
      end
    end

    def display_total
      Spree::Money.new(total, { currency: order.currency })
    end

    def calculated_total
      # rounding down to handle edge cases for consecutive partial returns where rounding
      # might cause us to try to reimburse more than was originally billed
      return_items.to_a.sum(&:total).to_d.round(2, :down)
    end

    def paid_amount
      reimbursement_models.sum do |model|
        model.total_amount_reimbursed_for(self)
      end
    end

    def unpaid_amount
      total - paid_amount
    end

    def perform!(created_by:)
      reimbursement_tax_calculator.call(self)
      reload
      update!(total: calculated_total)

      reimbursement_performer.perform(self, created_by:)

      if unpaid_amount_within_tolerance?
        reimbursed!
        Spree::Bus.publish :reimbursement_reimbursed, reimbursement: self
      else
        errored!
        Spree::Bus.publish :reimbursement_errored, reimbursement: self
      end

      if errored?
        raise IncompleteReimbursementError, I18n.t("spree.validation.unpaid_amount_not_zero", amount: unpaid_amount)
      end
    end

    def simulate(created_by:)
      reimbursement_simulator_tax_calculator.call(self)
      reload
      update!(total: calculated_total)

      reimbursement_performer.simulate(self, created_by:)
    end

    def return_items_requiring_exchange
      return_items.select(&:exchange_required?)
    end

    def any_exchanges?
      return_items.any?(&:exchange_processed?)
    end

    def all_exchanges?
      return_items.all?(&:exchange_processed?)
    end

    # Accepts all return items, saves the reimbursement, and performs the reimbursement
    #
    # @api public
    # @param [Spree.user_class] created_by the user that is performing this action
    # @return [void]
    def return_all(created_by:)
      return_items.each(&:accept!)
      save!
      perform!(created_by:)
    end

    # The returned category is used as the category
    # for Spree::Reimbursement::Credit.default_creditable_class.
    #
    # @return [Spree::StoreCreditCategory]
    def store_credit_category
      Spree::StoreCreditCategory.find_by(name: Spree::StoreCreditCategory::REIMBURSEMENT)
    end

    private

    def calculate_total
      self.total ||= calculated_total
    end

    def generate_number
      self.number ||= loop do
        random = "RI#{Array.new(9){ rand(9) }.join}"
        break random unless self.class.exists?(number: random)
      end
    end

    def validate_return_items_belong_to_same_order
      if return_items.any? { |ri| ri.inventory_unit.order_id != order_id }
        errors.add(:base, :return_items_order_id_does_not_match)
      end
    end

    # If there are multiple different reimbursement types for a single
    # reimbursement we open ourselves to a one-cent rounding error for every
    # type over the first one. This is due to how we round #unpaid_amount and
    # how each reimbursement type will round as well. Since at this point the
    # payments and credits have already been processed, we should allow the
    # reimbursement to show as 'reimbursed' and not 'errored'.
    def unpaid_amount_within_tolerance?
      reimbursement_count = reimbursement_models.count do |model|
        model.total_amount_reimbursed_for(self) > 0
      end
      leniency = if reimbursement_count > 0
                   (reimbursement_count - 1) * 0.01.to_d
                 else
                   0
                 end
      unpaid_amount.abs.between?(0, leniency)
    end
  end
end
