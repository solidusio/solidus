# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Variant do
  let(:product) { create(:product) }
  subject(:variant) { product.master }
  describe "#undiscounted_price" do
    subject { variant.undiscounted_price }

    it "raises an exception if called before discounting" do
      expect { subject }.to raise_exception(SolidusPromotions::VariantPatch::VariantNotDiscounted)
    end

    context "if variant is discounted" do
      let(:order) { Spree::Order.create }
      let(:pricing_options) { Spree::Config.pricing_options_class.new }
      before do
        SolidusPromotions::ProductDiscounter.new(product:, order:, pricing_options:).call
      end

      it "is the same as the variant price" do
        expect(subject).to eq(variant.price)
      end
    end
  end
end
