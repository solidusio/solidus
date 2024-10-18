# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionAdvertiser, type: :model do
  describe ".for_product" do
    subject { described_class.for_product(product) }

    let(:product) { create(:product) }
    let!(:promotion) { create(:promotion, :with_action, advertise: true, starts_at: 1.day.ago) }
    let!(:rule) do
      Spree::Promotion::Rules::Product.create(
        promotion:,
        products: [product]
      )
    end

    it "lists the promotion as a possible promotion" do
      expect(subject).to include(promotion)
    end
  end
end
