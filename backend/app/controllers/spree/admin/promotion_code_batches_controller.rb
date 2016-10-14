module Spree
  module Admin
    class PromotionCodeBatchesController < ResourceController
      belongs_to 'spree/promotion'

      create.after :build_promotion_code_batch

      def download
        require "csv"

        @promotion_code_batch = Spree::PromotionCodeBatch.find(
          id: params[:promotion_code_batch_id]
        )

        respond_to do |format|
          format.csv do
            filename = "promotion-code-batch-list-#{@promotion_code_batch.id}.csv"
            headers["Content-Type"] = "text/csv"
            headers["Content-disposition"] = "attachment; filename=\"#{filename}\""
          end
        end
      end

      private

      def build_promotion_code_batch
        @promotion_code_batch.process
      end
    end
  end
end
