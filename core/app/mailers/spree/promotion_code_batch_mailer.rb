module Spree
  class PromotionCodeBatchMailer < ApplicationMailer
    def promotion_code_batch_finished(promotion_code_batch)
      mail(
        to: promotion_code_batch.email,
        body: Spree.t(
          "promotion_code_batches.finished",
          number_of_codes: promotion_code_batch.number_of_codes
        ),
        subject: Spree.t(
          "promotion_code_batches.email_subject.batch_finished",
          promotion_code_batch_id: promotion_code_batch.id
        ),
      )
    end

    def promotion_code_batch_errored(promotion_code_batch)
      mail(
        to: promotion_code_batch.email,
        body: Spree.t(
        "promotion_code_batches.errored",
          error: promotion_code_batch.error
        ),
        subject: Spree.t(
          "promotion_code_batches.email_subject.batch_errored",
          promotion_code_batch_id: promotion_code_batch.id
        ),
      )
    end
  end
end
