# frozen_string_literal: true

module SolidusFriendlyPromotions
  module PromotionHandler
    class Page
      attr_reader :order, :path

      def initialize(order, path)
        @order = order
        @path = path.gsub(/\A\//, "")
      end

      def activate
        if promotion
          Spree::Config.promotions.order_adjuster_class.new(order, dry_run_promotion: promotion).call
          if promotion.eligibility_results.success?
            order.friendly_promotions << promotion
            order.recalculate
          end
        end
      end

      private

      def promotion
        @promotion ||= SolidusFriendlyPromotions::Promotion.active.find_by(path: path)
      end
    end
  end
end
