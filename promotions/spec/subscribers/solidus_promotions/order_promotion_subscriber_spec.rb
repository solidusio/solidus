# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderPromotionSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_emptied)

    described_class.new.subscribe_to(bus)
  end

  describe "on :order_emptied" do
    it "clears connected promotions" do
      promotion = create(:solidus_promotion)
      order = create(:order)
      order.solidus_promotions << promotion
      expect(order.solidus_promotions).not_to be_empty

      bus.publish(:order_emptied, order: order)
      expect(order.solidus_promotions.reload).to be_empty
    end
  end
end
