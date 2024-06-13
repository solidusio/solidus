# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::OrderPromotionSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_emptied)

    described_class.new.subscribe_to(bus)
  end

  describe "on :order_emptied" do
    it "clears connected promotions" do
      promotion = create(:friendly_promotion)
      order = create(:order)
      order.friendly_promotions << promotion
      expect(order.friendly_promotions).not_to be_empty

      bus.publish(:order_emptied, order: order)
      expect(order.friendly_promotions.reload).to be_empty
    end
  end
end
