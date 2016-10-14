module Spree
  class PromotionCodeBatchJob < ActiveJob::Base
    queue_as :default

    def perform(promotion_batch)
      PromotionCode::BatchBuilder.new(
        promotion_batch
      ).build_promotion_codes
    end
  end
end
