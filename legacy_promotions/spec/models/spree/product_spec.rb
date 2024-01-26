# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Product do
  describe "#discard" do
    let(:product) { create(:product, slug: "my-awesome-product") }
    it "removes from product promotion rules" do
      promotion = create(:promotion)
      rule = promotion.rules.create!(type: "Spree::Promotion::Rules::Product", products: [product])

      product.discard

      rule.reload
      expect(rule.products).to be_empty
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4416
  context "#possible_promotions" do
    let(:product) { create(:product) }
    let!(:promotion) { create(:promotion, :with_action, advertise: true, starts_at: 1.day.ago) }
    let!(:rule) do
      Spree::Promotion::Rules::Product.create(
        promotion: promotion,
        products: [product]
      )
    end

    it "lists the promotion as a possible promotion" do
      expect(product.possible_promotions).to include(promotion)
    end
  end
end
