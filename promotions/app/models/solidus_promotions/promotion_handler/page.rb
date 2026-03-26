# frozen_string_literal: true

module SolidusPromotions
  module PromotionHandler
    class Page
      attr_reader :order, :path, :checker

      def initialize(order, path)
        @order = order
        @path = path.delete_prefix("/")
        @checker = Spree::Config.promotions.eligibility_checker_class.new(order: order, promotion: promotion)
      end

      delegate :results, to: :checker

      def activate
        if promotion && checker.call
          order.solidus_promotions << promotion
          order.recalculate
        end
      end

      private

      def promotion
        @promotion ||= SolidusPromotions::Promotion.active.find_by(path: path)
      end
    end
  end
end
