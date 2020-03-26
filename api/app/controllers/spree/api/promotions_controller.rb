# frozen_string_literal: true

module Spree
  module Api
    class PromotionsController < Spree::Api::BaseController
      before_action :load_promotion

      def show
        authorize! :read, @promotion
        respond_with(@promotion, default_template: :show)
      end

      private

      def load_promotion
        @promotion = Spree::Promotion.with_coupon_code(params[:id]) || Spree::Promotion.find(params[:id])
      end
    end
  end
end
