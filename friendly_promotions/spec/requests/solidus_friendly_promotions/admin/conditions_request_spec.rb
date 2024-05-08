# frozen_string_literal: true

require "spec_helper"

describe "Admin::Conditions", type: :request do
  let!(:promotion) { create(:friendly_promotion, :with_adjustable_action) }
  let(:benefit) { promotion.actions.first }

  context "when the user is authorized" do
    stub_authorization! do |_u|
      Spree::PermissionSets::PromotionManagement.new(self).activate!
    end

    it "can create a promotion condition of a valid type" do
      post solidus_friendly_promotions.admin_promotion_benefit_conditions_path(promotion, benefit), params: {
        condition: {type: "SolidusFriendlyPromotions::Conditions::Product"}
      }
      expect(response).to be_redirect
      expect(response).to redirect_to solidus_friendly_promotions.edit_admin_promotion_path(promotion)
      expect(benefit.conditions.count).to eq(1)
    end

    it "can not create a promotion condition of an invalid type" do
      post solidus_friendly_promotions.admin_promotion_benefit_conditions_path(promotion, benefit), params: {
        condition: {type: "Spree::InvalidType"}
      }
      expect(response).to be_redirect
      expect(response).to redirect_to solidus_friendly_promotions.edit_admin_promotion_path(promotion)
      expect(benefit.conditions.count).to eq(0)
    end
  end

  context "when the user is not authorized" do
    it "redirects the user to login" do
      post solidus_friendly_promotions.admin_promotion_benefit_conditions_path(promotion, benefit), params: {
        condition: {type: "SolidusFriendlyPromotions::Conditions::Product"}
      }
      expect(response).to redirect_to("/admin/login")
    end
  end
end
