# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionCodeBatchMailer < Spree::BaseMailer
    def promotion_code_batch_finished(code_batch)
      @code_batch = code_batch
      mail(to: code_batch.email)
    end

    def promotion_code_batch_errored(code_batch)
      @code_batch = code_batch
      mail(to: code_batch.email)
    end
  end
end
