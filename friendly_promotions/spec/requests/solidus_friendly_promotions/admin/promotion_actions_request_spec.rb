# frozen_string_literal: true

require "spec_helper"

describe "Admin::PromotionActions", type: :request do
  stub_authorization!

  let!(:promotion) { create(:friendly_promotion) }

  it "can create a promotion action of a valid type" do
    post solidus_friendly_promotions.admin_promotion_promotion_actions_path(promotion_id: promotion.id), params: {
      promotion_action: {
        type: "SolidusFriendlyPromotions::Actions::AdjustLineItem",
        calculator_attributes: {type: "SolidusFriendlyPromotions::Calculators::FlatRate"}
      }
    }
    expect(response).to be_redirect
    expect(response).to redirect_to spree.edit_admin_promotion_path(promotion)
    expect(promotion.actions.count).to eq(1)
  end

  it "can not create a promotion action of an invalid type" do
    post solidus_friendly_promotions.admin_promotion_promotion_actions_path(promotion_id: promotion.id), params: {
      promotion_action: {type: "Spree::InvalidType"}
    }
    expect(response).to be_redirect
    expect(response).to redirect_to spree.edit_admin_promotion_path(promotion)
    expect(promotion.actions.count).to eq(0)
  end
end
