# frozen_string_literal: true

module Spree
  module Admin
    module PromotionsHelper
      def admin_promotion_status(promotion)
        return :active if promotion.active?
        return :not_started if promotion.not_started?
        return :expired if promotion.expired?

        :inactive
      end
    end
  end
end
