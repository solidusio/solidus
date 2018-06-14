# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class TimeSincePurchase < Spree::Settlement::EligibilityValidator::BaseValidator
        def eligible_for_settlement?
          if (@settlement.reimbursement.order.completed_at + Spree::Config[:settlement_eligibility_number_of_days].days) > Time.current
            true
          else
            add_error(:number_of_days, I18n.t('spree.settlement_time_period_ineligible'))
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
