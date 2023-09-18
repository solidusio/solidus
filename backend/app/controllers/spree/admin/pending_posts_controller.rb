# app/controllers/spree/admin/pending_posts_controller.rb
module Spree
  module Admin
    class PendingPostsController < Spree::Admin::BaseController
      def index
        @pending_posts = Spree::Product.all.where(is_pending: true)
      end

      def approve
        product = Spree::Product.find(params[:id])
        if product.update(is_approved: true, is_pending: false, reason: nil)
          render json: { success: true }
        else
          render json: { success: false, errors: product.errors.full_messages }, status: :unprocessable_entity
        end
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
