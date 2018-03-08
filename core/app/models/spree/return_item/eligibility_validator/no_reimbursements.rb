# frozen_string_literal: true

module Spree
  class ReturnItem < Spree::Base
    module EligibilityValidator
      class NoReimbursements < Spree::ReturnItem::EligibilityValidator::BaseValidator
        def eligible_for_return?
          if @return_item.inventory_unit.return_items.reimbursed.valid.any?
            add_error(:inventory_unit_reimbursed, I18n.t('spree.return_item_inventory_unit_reimbursed'))
            false
          else
            true
          end
        end

        def requires_manual_intervention?
          @errors.present?
        end
      end
    end
  end
end
