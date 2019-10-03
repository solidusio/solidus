# frozen_string_literal: true

module Solidus
  module PromotionHandler
    class Page
      attr_reader :order, :path

      def initialize(order, path)
        @order = order
        @path = path.gsub(/\A\//, '')
      end

      def activate
        if promotion && promotion.eligible?(order)
          promotion.activate(order: order)
        end
      end

      private

      def promotion
        @promotion ||= Solidus::Promotion.active.find_by(path: path)
      end
    end
  end
end
