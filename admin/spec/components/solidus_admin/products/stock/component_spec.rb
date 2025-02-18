# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Products::Stock::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  describe ".from_variant" do
    it "has an empty variants count" do
      allow(described_class).to receive(:new)

      described_class.from_variant(instance_double(Spree::Variant, total_on_hand: 123))

      expect(described_class).to have_received(:new).with(
        on_hand: 123,
        variants_count: nil
      )
    end
  end

  describe ".from_product" do
    it "has an empty variants count" do
      allow(described_class).to receive(:new)

      described_class.from_product(instance_double(Spree::Product, total_on_hand: 123, variants: []))

      expect(described_class).to have_received(:new).with(
        on_hand: 123,
        variants_count: 0
      )
    end
  end
end
