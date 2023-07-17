# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionAdjustmentChooser
    attr_reader :adjustable

    def initialize(adjustable)
      @adjustable = adjustable
    end

    def call(adjustments)
      Array.wrap(
        adjustments.min_by do |adjustment|
          [adjustment.amount, -adjustment.source&.id.to_i]
        end
      )
    end
  end
end
