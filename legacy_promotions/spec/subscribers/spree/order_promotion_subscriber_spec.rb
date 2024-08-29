# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::OrderPromotionSubscriber do
  let(:bus) { Omnes::Bus.new }

  before do
    bus.register(:order_emptied)

    described_class.new.subscribe_to(bus)
  end

  describe "on :order_emptied" do
    it "clears connected promotions" do
      promotion = create(:promotion)
      order = create(:order)
      order.promotions << promotion
      expect(order.order_promotions).not_to be_empty

      bus.publish(:order_emptied, order:)
      expect(order.order_promotions).to be_empty
    end
  end
end
