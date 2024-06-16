# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Benefits", type: :request do
  stub_authorization!

  let!(:promotion) { create(:friendly_promotion) }

  it "can create a promotion benefit of a valid type" do
    post solidus_friendly_promotions.admin_promotion_benefits_path(promotion_id: promotion.id), params: {
      benefit: {
        type: "SolidusFriendlyPromotions::Benefits::AdjustLineItem",
        calculator_attributes: {type: "SolidusFriendlyPromotions::Calculators::FlatRate"}
      }
    }
    expect(response).to be_redirect
    expect(response).to redirect_to solidus_friendly_promotions.edit_admin_promotion_path(promotion)
    expect(promotion.benefits.count).to eq(1)
  end

  it "can not create a promotion benefit of an invalid type" do
    post solidus_friendly_promotions.admin_promotion_benefits_path(promotion_id: promotion.id), params: {
      benefit: {type: "Spree::InvalidType"}
    }
    expect(response).to be_redirect
    expect(response).to redirect_to solidus_friendly_promotions.edit_admin_promotion_path(promotion)
    expect(promotion.benefits.count).to eq(0)
  end
end
