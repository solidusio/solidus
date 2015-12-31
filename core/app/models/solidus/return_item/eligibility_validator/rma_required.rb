module Solidus
  class ReturnItem::EligibilityValidator::RMARequired < Solidus::ReturnItem::EligibilityValidator::BaseValidator
    def eligible_for_return?
      if @return_item.return_authorization.present?
        return true
      else
        add_error(:rma_required, Solidus.t('return_item_rma_ineligible'))
        return false
      end
    end

    def requires_manual_intervention?
      false
    end
  end
end

