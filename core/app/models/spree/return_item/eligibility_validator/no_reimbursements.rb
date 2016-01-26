module Spree
  class ReturnItem::EligibilityValidator::NoReimbursements < Spree::ReturnItem::EligibilityValidator::BaseValidator
    def eligible_for_return?
      if @return_item.inventory_unit.return_items.reimbursed.valid.any?
        add_error(:inventory_unit_reimbursed, Spree.t('return_item_inventory_unit_reimbursed'))
        return false
      else
        return true
      end
    end

    def requires_manual_intervention?
      @errors.present?
    end
  end
end
