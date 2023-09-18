# app/controllers/spree/admin/rejected_posts_controller.rb
module Spree
  module Admin
    class RejectedPostsController < Spree::Admin::BaseController
      def index
        @rejected_posts = Spree::Product.all.where(is_rejected: true)
      end

      def approve
        product = Spree::Product.find(params[:id])
        if product.update(is_rejected: false, is_approved: true, is_pending: false, reason: nil)
          render json: { success: true }
        else
          render json: { success: false, errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def pending
        product = Spree::Product.find(params[:id])
        if product.update(is_rejected: false, is_approved: false, is_pending: true, reason: params[:reason])
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
