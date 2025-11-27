# frozen_string_literal: true

module SolidusPromotions
  class PromotionLane < ActiveSupport::CurrentAttributes
    attribute :current

    def ordered
      Promotion.lanes.keys.sort_by { |lane| Promotion.lanes[lane] }
    end

    def before(lane)
      ordered.split(lane.to_s).first
    end

    def before_current
      return ordered unless current
      before(current)
    end
  end
end
