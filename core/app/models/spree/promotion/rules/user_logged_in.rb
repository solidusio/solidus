# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Rules
      class UserLoggedIn < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          unless order.user.present?
            eligibility_errors.add(:base, eligibility_error_message(:no_user_specified), error_code: :no_user_specified)
          end
          eligibility_errors.empty?
        end
      end
    end
  end
end
