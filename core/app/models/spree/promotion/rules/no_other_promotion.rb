# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base

    module Rules
      class NoOtherPromotion < PromotionRule

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          if order.promotions.present?
            eligibility_errors.add(:base, eligibility_error_message(:order_has_other_promotion))
          end

          eligibility_errors.empty?
        end

      end
    end

  end
end
