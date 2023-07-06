# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionCodeBatchJob < ActiveJob::Base
    queue_as :default

    def perform(code_batch)
      PromotionCode::BatchBuilder.new(
        code_batch
      ).build_promotion_codes

      if code_batch.email?
        SolidusFriendlyPromotions.config.code_batch_mailer_class
          .code_batch_finished(code_batch)
          .deliver_now
      end
    rescue StandardError => error
      if code_batch.email?
        SolidusFriendlyPromotions.config.code_batch_mailer_class
          .code_batch_errored(code_batch)
          .deliver_now
      end
      raise error
    end
  end
end
