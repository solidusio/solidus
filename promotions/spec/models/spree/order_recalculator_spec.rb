# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Config.order_recalculator_class do
  let(:order) { create(:order) }
  subject { described_class.new(order).recalculate }

  it "calls the order promotion syncer" do
    expect(SolidusPromotions::MigrationSupport::OrderPromotionSyncer).not_to receive(:new)
    subject
  end

  context "if config option is set to false" do
    around do |example|
      SolidusPromotions.config.sync_order_promotions = true
      example.run
      SolidusPromotions.config.sync_order_promotions = false
    end

    it "does not call the order promotion syncer" do
      expect_any_instance_of(SolidusPromotions::MigrationSupport::OrderPromotionSyncer).to receive(:call)
      subject
    end
  end
end
