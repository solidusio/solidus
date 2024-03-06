# frozen_string_literal: true

module Spree
  module Api
    class PromotionsController < Spree::Api::BaseController
      before_action :load_promotion

      def show
        authorize! :show, @promotion
        respond_with(@promotion, default_template: :show)
      end

      private

      def load_promotion
        @promotion = Spree::Config.promotions.promotion_finder_class.by_code_or_id(params[:id])
      end
    end
  end
end
