# frozen_string_literal: true

module SolidusPromotions
  module PromotionHandler
    class Page
      attr_reader :order, :path

      def initialize(order, path)
        @order = order
        @path = path.delete_prefix('/')
      end

      def activate
        if promotion
          Spree::Config.promotions.order_adjuster_class.new(order, dry_run_promotion: promotion).call
          if promotion.eligibility_results.success?
            order.solidus_promotions << promotion
            order.recalculate
          end
        end
      end

      private

      def promotion
        @promotion ||= SolidusPromotions::Promotion.active.find_by(path: path)
      end
    end
  end
end
