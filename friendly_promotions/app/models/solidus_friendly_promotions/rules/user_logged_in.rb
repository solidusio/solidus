# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class UserLoggedIn < PromotionRule
      include OrderLevelRule

      def eligible?(order, _options = {})
        if order.user.blank?
          eligibility_errors.add(:base, eligibility_error_message(:no_user_specified), error_code: :no_user_specified)
        end
        eligibility_errors.empty?
      end
    end
  end
end
