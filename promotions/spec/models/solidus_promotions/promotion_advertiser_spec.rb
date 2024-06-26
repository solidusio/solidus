# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::PromotionAdvertiser, type: :model do
  describe ".for_product" do
    subject { described_class.for_product(product) }

    let(:product) { create(:product) }
    let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, advertise: true, starts_at: 1.day.ago) }
    let!(:rule) do
      SolidusPromotions::Conditions::LineItemProduct.create(
        benefit: promotion.benefits.first,
        products: [product]
      )
    end

    it "lists the promotion as a possible promotion" do
      expect(subject).to include(promotion)
    end
  end
end
