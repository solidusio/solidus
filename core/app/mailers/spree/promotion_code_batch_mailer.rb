module Spree
  class PromotionCodeBatchMailer < ApplicationMailer
    def promotion_code_batch_finished(promotion_code_batch)
      mail(
        to: promotion_code_batch.email,
        body: Spree.t(
          "promotion_code_batches.finished",
          number_of_codes: promotion_code_batch.number_of_codes
        )
      )
    end

    def promotion_code_batch_errored(promotion_code_batch)
      mail(
        to: promotion_code_batch.email,
        body: Spree.t(
          "promotion_code_batches.errored",
          error: promotion_code_batch.error
        )
      )
    end
  end
end
