# frozen_string_literal: true

module Solidus
  class ReturnItem < Solidus::Base
    module EligibilityValidator
      class Default < Solidus::ReturnItem::EligibilityValidator::BaseValidator
        class_attribute :permitted_eligibility_validators
        self.permitted_eligibility_validators = [
          ReturnItem::EligibilityValidator::OrderCompleted,
          ReturnItem::EligibilityValidator::TimeSincePurchase,
          ReturnItem::EligibilityValidator::RMARequired,
          ReturnItem::EligibilityValidator::InventoryShipped,
          ReturnItem::EligibilityValidator::NoReimbursements
        ]

        def eligible_for_return?
          validators.all?(&:eligible_for_return?)
        end

        def requires_manual_intervention?
          validators.any?(&:requires_manual_intervention?)
        end

        def errors
          validators.map(&:errors).reduce({}, :merge)
        end

        private

        def validators
          @validators ||= permitted_eligibility_validators.map{ |v| v.new(@return_item) }
        end
      end
    end
  end
end
