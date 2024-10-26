# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::PromotionCategory, type: :model do
  it { is_expected.to have_many :promotions }

  describe "validation" do
    subject { described_class.new name: name }

    let(:name) { "Nom" }

    context "when all required attributes are specified" do
      it { is_expected.to be_valid }
    end

    context "when name is missing" do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe "associations" do
    let!(:promotion) { create(:solidus_promotion, category: category) }
    let(:category) { create(:solidus_promotion_category) }

    it "nullifies associated promotions when deleted" do
      category.destroy
      expect(promotion.reload.promotion_category_id).to be_nil
    end
  end
end
