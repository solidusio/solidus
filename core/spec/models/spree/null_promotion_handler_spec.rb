# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::NullPromotionHandler do
  let(:order) { double(Spree::Order, coupon_code: "NULL") }
  subject(:handler) { described_class.new(order) }

  describe "#activate" do
    subject(:activate) { handler.activate }

    it "returns the unchanged order" do
      expect(activate).to eq(order)
    end
  end

  describe "#can_apply?" do
    subject { handler.can_apply? }
    let(:order) { double(Spree::Order, coupon_code: nil) }

    it { is_expected.to be true }
  end

  describe "#status" do
    subject { handler.status }

    it { is_expected.to eq("Coupon code has been applied.") }
  end

  describe "#status_code" do
    subject { handler.status_code }

    it { is_expected.to eq(:coupon_code_applied) }
  end

  describe "#error" do
    subject { handler.error }

    it { is_expected.to be nil }
  end

  describe "#coupon_code" do
    subject { handler.coupon_code }

    it { is_expected.to eq 'null' }
  end

  describe "#success" do
    subject { handler.success }

    it { is_expected.to be true }
  end

  describe "#successful?" do
    subject { handler.successful? }

    it { is_expected.to be true }
  end
end
