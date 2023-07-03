# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::Promotion, type: :model do
  let(:promotion) { described_class.new }

  it { is_expected.to belong_to(:category).optional }

  describe "validations" do
    before :each do
      @valid_promotion = described_class.new name: "A promotion"
    end

    it "valid_promotion is valid" do
      expect(@valid_promotion).to be_valid
    end

    it "validates usage limit" do
      @valid_promotion.usage_limit = -1
      expect(@valid_promotion).not_to be_valid

      @valid_promotion.usage_limit = 100
      expect(@valid_promotion).to be_valid
    end

    it "validates name" do
      @valid_promotion.name = nil
      expect(@valid_promotion).not_to be_valid
    end
  end
end
