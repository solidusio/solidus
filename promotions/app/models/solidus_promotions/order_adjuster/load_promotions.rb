# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    class LoadPromotions < SolidusPromotions::LoadPromotions
      def initialize(...)
        Spree.deprecator.warn("Please use SolidusPromotions::LoadPromotions instead")
        super
      end
    end
  end
end
