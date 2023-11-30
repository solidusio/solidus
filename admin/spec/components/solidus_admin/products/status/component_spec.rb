# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Products::Status::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  describe "#status" do
    it "returns :available when the product is available" do
      product = Spree::Product.new(available_on: Time.current)

      render_inline described_class.from_product(product)

      expect(rendered_content).to have_text("Available")
    end

    it "returns :discontinued when the product is not available" do
      product = Spree::Product.new(available_on: nil)

      render_inline described_class.from_product(product)

      within('tbody') { expect(rendered_content).to have_text("Discontinued") }
    end
  end
end
