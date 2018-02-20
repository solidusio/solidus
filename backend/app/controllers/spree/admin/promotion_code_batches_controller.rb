# frozen_string_literal: true

module Spree
  module Admin
    class PromotionCodeBatchesController < ResourceController
      belongs_to 'spree/promotion'

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
    end
  end
end
