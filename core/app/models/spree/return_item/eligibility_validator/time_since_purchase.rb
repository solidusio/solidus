# frozen_string_literal: true

module Spree
  class ReturnItem < Spree::Base
    module EligibilityValidator
      class TimeSincePurchase < Spree::ReturnItem::EligibilityValidator::BaseValidator
        def eligible_for_return?
          if (@return_item.inventory_unit.order.completed_at + Spree::Config[:return_eligibility_number_of_days].days) > Time.current
            true
          else
            add_error(:number_of_days, I18n.t('spree.return_item_time_period_ineligible'))
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
