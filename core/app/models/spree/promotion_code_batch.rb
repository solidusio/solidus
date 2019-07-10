# frozen_string_literal: true

module Spree
  class PromotionCodeBatch < ActiveRecord::Base
    class CantProcessStartedBatch < StandardError
    end

    belongs_to :promotion, class_name: "Spree::Promotion", optional: true
    has_many :promotion_codes, class_name: "Spree::PromotionCode", dependent: :destroy

    validates :number_of_codes, numericality: { greater_than: 0 }
    validates_presence_of :base_code, :number_of_codes

    def finished?
      state == "completed"
    end

    def process
      if state == "pending"
        update!(state: "processing")
        PromotionCodeBatchJob.perform_later(self)
      else
        raise CantProcessStartedBatch.new("Batch #{id} already started")
      end
    end
  end
end
