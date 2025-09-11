# frozen_string_literal: true

module Spree
  module PromotionHandler
    class Page
      attr_reader :order, :path

      def initialize(order, path)
        @order = order
        @path = path.delete_prefix("/")
      end

      def activate
        if promotion&.eligible?(order)
          promotion.activate(order:)
        end
      end

      private

      def promotion
        @promotion ||= Spree::Promotion.active.find_by(path:)
      end
    end
  end
end
