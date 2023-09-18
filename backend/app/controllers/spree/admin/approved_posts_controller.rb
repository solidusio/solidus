# app/controllers/spree/admin/approved_posts_controller.rb
module Spree
  module Admin
    class ApprovedPostsController < Spree::Admin::BaseController
      def index
        @approved_posts = Spree::Product.all.where(is_approved: true)
      end

      def reject
        product = Spree::Product.find(params[:id])
        if product.update(is_rejected: true, is_approved: false, is_pending: false, reason: params[:reason])
          render json: { success: true }
        else
          render json: { success: false, errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def withdraw
        product = Spree::Product.find(params[:id])
        if product.destroy
          render json: { success: true }
        else
          render json: { success: false }, status: :unprocessable_entity
        end
      end
    end
  end
end
