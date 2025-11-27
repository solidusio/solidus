# frozen_string_literal: true

module SolidusPromotions
  # PromotionLane is a thread-safe current attributes class that manages the current promotion lane context.
  #
  # This class extends ActiveSupport::CurrentAttributes to provide thread-local storage for the current
  # promotion lane. It allows setting and retrieving the current lane, as well as getting all lanes
  # that come before the current one.
  #
  # @example Setting and retrieving the current lane
  #   PromotionLane.current_lane = :pre
  #   PromotionLane.current_lane # => "pre"
  #
  # @example Getting lanes before the current one
  #   PromotionLane.current_lane = :post
  #   PromotionLane.previous_lanes # => ["pre"]
  #
  # @see ActiveSupport::CurrentAttributes
  class PromotionLane < ActiveSupport::CurrentAttributes
    attribute :current_lane

    def current_lane=(arg)
      if arg.present?
        super(arg.to_s)
      else
        super
      end
    end

    # Retrieves the lanes that occur before the current lane in the promotion flow.
    #
    # Delegates to `before(current_lane)` to compute the preceding lanes.
    #
    # Special considerations:
    # - If `current_lane` is `nil`, all lanes are returned.
    #
    # @return [Array<String>] the set of lanes preceding the current lane; all lanes if no current lane is set
    def previous_lanes
      before(current_lane)
    end

    private

    def before(lane)
      Promotion.ordered_lanes.split(lane).first
    end
  end
end
