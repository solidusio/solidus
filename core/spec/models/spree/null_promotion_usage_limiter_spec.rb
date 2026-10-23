# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::NullPromotionUsageLimiter do
  let(:order) { instance_double(Spree::Order) }

  subject(:limiter) { described_class.new(order) }

  describe "#claim" do
    it "yields" do
      expect { |block| limiter.claim(&block) }.to yield_control
    end
  end

  describe "#release" do
    it "does nothing" do
      expect(limiter.release).to be_nil
    end
  end

  describe "#reclaim" do
    it "does nothing" do
      expect(limiter.reclaim).to be_nil
    end
  end
end
