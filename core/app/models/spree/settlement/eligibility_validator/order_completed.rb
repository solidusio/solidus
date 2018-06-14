# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class OrderCompleted < Spree::Settlement::EligibilityValidator::BaseValidator
        def eligible_for_settlement?
          if @settlement.reimbursement.order.completed?
            true
          else
            add_error(:order_not_completed, I18n.t('spree.settlement_order_not_completed'))
            false
          end
        end

        def requires_manual_intervention?
          false
        end
      end
    end
  end
end
