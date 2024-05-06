# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::ApiConfiguration do
  subject(:config) { Spree::ApiConfiguration.new }

  describe "#promotion_attributes" do
    subject(:promotion_attributes) { config.promotion_attributes }

    it { is_expected.to eq(Spree::Config.promotions.promotion_api_attributes) }

    it "can be changed" do
      config.promotion_attributes << :foo
      expect(promotion_attributes).to include(:foo)
    end

    it "can delete attributes" do
      expect(promotion_attributes).to include(:name)
      config.promotion_attributes.delete(:name)
      expect(promotion_attributes).not_to include(:name)
    end
  end

  describe "#promotion_attributes=" do
    subject(:promotion_attributes_setter) { config.promotion_attributes = [:name] }

    around do |example|
      original_attributes = Spree::Config.promotions.promotion_api_attributes
      Spree.deprecator.silence do
        example.run
      end
      Spree::Config.promotions.promotion_api_attributes = original_attributes
    end

    it "sets the promotion_attributes" do
      promotion_attributes_setter
      expect(config.promotion_attributes).to eq([:name])
    end
  end
end
