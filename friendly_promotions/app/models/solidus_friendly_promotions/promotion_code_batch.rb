# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionCodeBatch < Spree::Base
    class CantProcessStartedBatch < StandardError
    end

    belongs_to :promotion
    has_many :promotion_codes, dependent: :destroy

    validates :number_of_codes, numericality: {greater_than: 0}
    validates :base_code, :number_of_codes, presence: true

    def finished?
      state == "completed"
    end

    def process
      raise CantProcessStartedBatch, "Batch #{id} already started" unless state == "pending"

      update!(state: "processing")
      PromotionCodeBatchJob.perform_later(self)
    end
  end
end
