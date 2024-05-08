# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Conditions
    class FirstOrder < Condition
      include OrderLevelCondition
      attr_reader :user, :email

      def eligible?(order, options = {})
        @user = order.try(:user) || options[:user]
        @email = order.email

        if (user || email) && (completed_orders.present? && completed_orders.first != order)
          eligibility_errors.add(:base, eligibility_error_message(:not_first_order), error_code: :not_first_order)
        end

        eligibility_errors.empty?
      end

      private

      def completed_orders
        user ? user.orders.complete : orders_by_email
      end

      def orders_by_email
        Spree::Order.where(email: email).complete
      end
    end
  end
end
