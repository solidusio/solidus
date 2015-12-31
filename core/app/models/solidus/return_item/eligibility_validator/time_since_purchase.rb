module Spree
  class ReturnItem::EligibilityValidator::TimeSincePurchase < Solidus::ReturnItem::EligibilityValidator::BaseValidator
    def eligible_for_return?
      if (@return_item.inventory_unit.order.completed_at + Solidus::Config[:return_eligibility_number_of_days].days) > Time.current
        return true
      else
        add_error(:number_of_days, Solidus.t('return_item_time_period_ineligible'))
        return false
      end
    end

    def requires_manual_intervention?
      false
    end
  end
end
