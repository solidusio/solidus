# frozen_string_literal: true

module SolidusFriendlyPromotions
  class CodeBatchMailer < Spree::BaseMailer
    def code_batch_finished(code_batch)
      @code_batch = code_batch
      mail(to: code_batch.email)
    end

    def code_batch_errored(code_batch)
      @code_batch = code_batch
      mail(to: code_batch.email)
    end
  end
end
