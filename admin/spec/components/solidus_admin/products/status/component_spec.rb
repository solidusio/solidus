# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Products::Status::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  describe "#status" do
    it "returns :available when the product is available" do
      product = Spree::Product.new(available_on: Time.current)

      component = described_class.new(product: product)

      expect(component.status).to eq(:available)
    end

    it "returns :discontinued when the product is not available" do
      product = Spree::Product.new(available_on: nil)

      component = described_class.new(product: product)

      expect(component.status).to eq(:discontinued)
    end
  end
end
