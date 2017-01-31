module Spree
  class PromotionCodeBatchJob < ActiveJob::Base
    queue_as :default

    def perform(promotion_code_batch)
      PromotionCode::BatchBuilder.new(
        promotion_code_batch
      ).build_promotion_codes

      Spree::PromotionCodeBatchMailer
        .promotion_code_batch_finished(promotion_code_batch)
        .deliver_now
    rescue => e
      Spree::PromotionCodeBatchMailer
        .promotion_code_batch_errored(promotion_code_batch)
        .deliver_now
      raise e
    end
  end
end
