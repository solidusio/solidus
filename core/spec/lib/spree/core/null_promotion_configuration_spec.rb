# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::NullPromotionConfiguration do
  subject(:config) { described_class.new }

  it "uses the null promotion adjuster class by default" do
    expect(config.promotion_adjuster_class).to eq Spree::NullPromotionAdjuster
  end

  it "uses the null coupon code handler class by default" do
    expect(config.coupon_code_handler_class).to eq Spree::NullPromotionHandler
  end

  it "uses the null promotion finder class by default" do
    expect(config.promotion_finder_class).to eq Spree::NullPromotionFinder
  end
end
