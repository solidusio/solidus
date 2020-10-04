# frozen_string_literal: true

module Spree
  class ReturnItem < Spree::Base
    module EligibilityValidator
      class RMARequired < Spree::ReturnItem::EligibilityValidator::BaseValidator
        def eligible_for_return?
          if @return_item.return_authorization.present?
            true
          else
            add_error(:rma_required, I18n.t('spree.return_item_rma_ineligible'))
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
