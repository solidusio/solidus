# frozen_string_literal: true

module Spree
  class PromotionCodeBatch < Spree::Base
    class CantProcessStartedBatch < StandardError
    end

    belongs_to :promotion, class_name: "Spree::Promotion", optional: true
    has_many :promotion_codes, class_name: "Spree::PromotionCode", dependent: :destroy

    validates :number_of_codes, numericality: { greater_than: 0 }
    validates_presence_of :base_code, :number_of_codes

    def finished?
      state == "completed"
    end
  end
end
