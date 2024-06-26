# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class PromotionCodeBatchesController < BaseController
      belongs_to "solidus_promotions/promotion"

      create.after :build_promotion_code_batch

      def download
        require "csv"

        @promotion_code_batch = SolidusPromotions::PromotionCodeBatch.find(
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

      def model_class
        SolidusPromotions::PromotionCodeBatch
      end

      def collection
        parent.code_batches
      end

      def build_resource
        parent.code_batches.build
      end
    end
  end
end
