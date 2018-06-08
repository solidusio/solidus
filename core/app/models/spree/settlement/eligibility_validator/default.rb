# frozen_string_literal: true

module Spree
  class Settlement < Spree::Base
    module EligibilityValidator
      class Default < Spree::Settlement::EligibilityValidator::BaseValidator
        class_attribute :permitted_eligibility_validators
        self.permitted_eligibility_validators = [
          Settlement::EligibilityValidator::OrderCompleted,
          Settlement::EligibilityValidator::TimeSincePurchase,
          Settlement::EligibilityValidator::ShipmentShipped,
          Settlement::EligibilityValidator::ItemReturned
        ]

        def eligible_for_settlement?
          validators.all?(&:eligible_for_settlement?)
        end

        def requires_manual_intervention?
          validators.any?(&:requires_manual_intervention?)
        end

        def errors
          validators.map(&:errors).reduce({}, :merge)
        end

        private

        def validators
          @validators ||= permitted_eligibility_validators.map{ |v| v.new(@settlement) }
        end
      end
    end
  end
end
