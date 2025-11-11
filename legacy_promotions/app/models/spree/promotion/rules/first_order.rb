# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Rules
      class FirstOrder < PromotionRule
        attr_reader :user, :email

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, options = {})
          @user = order.try(:user) || options[:user]
          @email = order.email

          if (user || email) && completed_orders.present? && completed_orders.first != order
            eligibility_errors.add(:base, eligibility_error_message(:not_first_order), error_code: :not_first_order)
          end

          eligibility_errors.empty?
        end

        private

        def completed_orders
          user ? user.orders.complete.not_canceled : orders_by_email
        end

        def orders_by_email
          Spree::Order.where(email:).complete.not_canceled
        end
      end
    end
  end
end
