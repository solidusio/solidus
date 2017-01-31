module Spree
  class PromotionCodeBatchMailer < ApplicationMailer
    def promotion_code_batch_finished(promotion_code_batch)
      @promotion_code_batch = promotion_code_batch
      mail(to: promotion_code_batch.email)
    end

    def promotion_code_batch_errored(promotion_code_batch)
      @promotion_code_batch = promotion_code_batch
      mail(to: promotion_code_batch.email)
    end
  end
end
