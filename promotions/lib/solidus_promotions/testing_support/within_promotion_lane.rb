# frozen_string_literal: true

RSpec.configure do |config|
  SolidusPromotions::Promotion.ordered_lanes.each do |lane|
    config.before(:each, :"within_#{lane}_promotion_lane") do
      allow(SolidusPromotions::Promotion).to receive(:current_lane) { lane.to_s }
    end
  end
end
