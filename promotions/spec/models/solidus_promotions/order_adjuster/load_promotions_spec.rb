# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderAdjuster::LoadPromotions do
  let(:order) { Spree::Order.new }

  subject { described_class.new(order:) }

  it "tells the user to use SolidusPromotions::LoadPromotions instead" do
    expect(Spree.deprecator).to receive(:warn).with("Please use SolidusPromotions::LoadPromotions instead")
    expect(subject).to be_a(SolidusPromotions::LoadPromotions)
  end
end
