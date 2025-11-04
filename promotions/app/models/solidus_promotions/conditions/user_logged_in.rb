# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class UserLoggedIn < Condition
      def order_eligible?(order, _options = {})
        if order.user.blank?
          eligibility_errors.add(:base, eligibility_error_message(:no_user_specified), error_code: :no_user_specified)
        end
        eligibility_errors.empty?
      end
    end
  end
end
