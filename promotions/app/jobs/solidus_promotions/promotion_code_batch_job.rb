# frozen_string_literal: true

module SolidusPromotions
  class PromotionCodeBatchJob < ActiveJob::Base
    queue_as :default

    def perform(promotion_code_batch)
      PromotionCode::BatchBuilder.new(
        promotion_code_batch
      ).build_promotion_codes

      if promotion_code_batch.email?
        SolidusPromotions.config.promotion_code_batch_mailer_class
          .promotion_code_batch_finished(promotion_code_batch)
          .deliver_now
      end
    rescue => e
      if promotion_code_batch.email?
        SolidusPromotions.config.promotion_code_batch_mailer_class
          .promotion_code_batch_errored(promotion_code_batch)
          .deliver_now
      end
      raise e
    end
  end
end
