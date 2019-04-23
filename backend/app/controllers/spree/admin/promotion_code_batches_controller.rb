# frozen_string_literal: true

module Spree
  module Admin
    class PromotionCodeBatchesController < ResourceController
      belongs_to 'spree/promotion'

      before_action :set_breadcrumbs
      create.after :build_promotion_code_batch

      def download
        require "csv"

        @promotion_code_batch = Spree::PromotionCodeBatch.find(
          params[:promotion_code_batch_id]
        )

        send_data(
          render_to_string,
          filename: "promotion-code-batch-list-#{@promotion_code_batch.id}.csv"
        )
      end

      private

      def build_promotion_code_batch
        @promotion_code_batch.process
      end

      def set_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Promotion), spree.admin_promotions_path
        add_breadcrumb @promotion.name, spree.edit_admin_promotion_path(@promotion.id) if action_name == 'index'
        add_breadcrumb @promotion.name, spree.admin_promotion_path(@promotion.id)      if action_name == 'new'
        add_breadcrumb plural_resource_name(Spree::PromotionCodeBatch)
      end
    end
  end
end
