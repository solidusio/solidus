# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionAdjustmentChooser
    attr_reader :adjustable

    def initialize(adjustable)
      @adjustable = adjustable
    end

    def call(adjustments)
      Array.wrap(
        adjustments.select(&:eligible?).min_by do |adjustment|
          [adjustment.amount, -adjustment.id.to_i]
        end
      )
    end
  end
end
