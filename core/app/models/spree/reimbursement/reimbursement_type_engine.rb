# frozen_string_literal: true

module Spree
  class Reimbursement::ReimbursementTypeEngine
    include Spree::Reimbursement::ReimbursementTypeValidator

    class_attribute :refund_time_constraint
    self.refund_time_constraint = 90.days

    class_attribute :default_reimbursement_type
    self.default_reimbursement_type = Spree::ReimbursementType::OriginalPayment

    class_attribute :expired_reimbursement_type
    self.expired_reimbursement_type = Spree::ReimbursementType::StoreCredit

    class_attribute :exchange_reimbursement_type
    self.exchange_reimbursement_type = Spree::ReimbursementType::Exchange

    def initialize(reimbursement)
      @return_items = reimbursement.return_items
      @settlements = reimbursement.settlements
      @reimbursement_type_hash = Hash.new { |h, k| h[k] = [] }
    end

    def calculate_reimbursement_types
      @return_items.each do |return_item|
        reimbursement_type = calculate_return_item_reimbursement_type(return_item)
        add_reimbursement_type(return_item, reimbursement_type)
      end
      @settlements.accepted.each do |settlement|
        reimbursement_type = calculate_settlement_reimbursement_type(settlement)
        add_reimbursement_type(settlement, reimbursement_type)
      end

      @reimbursement_type_hash
    end

    private

    def calculate_return_item_reimbursement_type(return_item)
      if return_item.exchange_required?
        exchange_reimbursement_type
      elsif return_item.override_reimbursement_type.present?
        return_item.override_reimbursement_type.class
      elsif return_item.preferred_reimbursement_type.present?
        if valid_preferred_reimbursement_type?(return_item)
          return_item.preferred_reimbursement_type.class
        end
      elsif past_reimbursable_time_period?(return_item)
        expired_reimbursement_type
      else
        default_reimbursement_type
      end
    end

    def calculate_settlement_reimbursement_type(settlement)
      if settlement.reimbursement_type.present?
        if valid_settlement_reimbursement_type?(settlement)
          settlement.reimbursement_type.class
        end
      else
        default_reimbursement_type
      end
    end

    def add_reimbursement_type(reimbursement_item, reimbursement_type)
      return unless reimbursement_type
      @reimbursement_type_hash[reimbursement_type] << reimbursement_item
    end
  end
end
