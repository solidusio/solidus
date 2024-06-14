# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreePromotionCodeBatchDecorator
    def process
      if state == "pending"
        update!(state: "processing")
        Spree::PromotionCodeBatchJob.perform_later(self)
      else
        raise Spree::PromotionCodeBatch::CantProcessStartedBatch.new("Batch #{id} already started")
      end
    end

    Spree::PromotionCodeBatch.prepend(self)
  end
end
