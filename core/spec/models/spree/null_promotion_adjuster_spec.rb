# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::NullPromotionAdjuster do
  describe "#call" do
    subject(:call) { described_class.new(order).call }

    let(:order) { instance_double(Spree::Order) }

    it "returns the unchanged order" do
      expect(call).to eq(order)
    end
  end
end
