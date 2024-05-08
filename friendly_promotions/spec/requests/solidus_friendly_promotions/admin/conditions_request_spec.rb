# frozen_string_literal: true

require "spec_helper"

describe "Admin::PromotionRules", type: :request do
  let!(:promotion) { create(:friendly_promotion, :with_adjustable_action) }
  let(:promotion_action) { promotion.actions.first }

  context "when the user is authorized" do
    stub_authorization! do |_u|
      Spree::PermissionSets::PromotionManagement.new(self).activate!
    end

    it "can create a promotion rule of a valid type" do
      post solidus_friendly_promotions.admin_promotion_promotion_action_conditions_path(promotion, promotion_action), params: {
        promotion_rule: {type: "SolidusFriendlyPromotions::Rules::Product"}
      }
      expect(response).to be_redirect
      expect(response).to redirect_to solidus_friendly_promotions.edit_admin_promotion_path(promotion)
      expect(promotion_action.conditions.count).to eq(1)
    end

    it "can not create a promotion rule of an invalid type" do
      post solidus_friendly_promotions.admin_promotion_promotion_action_conditions_path(promotion, promotion_action), params: {
        promotion_rule: {type: "Spree::InvalidType"}
      }
      expect(response).to be_redirect
      expect(response).to redirect_to solidus_friendly_promotions.edit_admin_promotion_path(promotion)
      expect(promotion_action.conditions.count).to eq(0)
    end
  end

  context "when the user is not authorized" do
    it "redirects the user to login" do
      post solidus_friendly_promotions.admin_promotion_promotion_action_conditions_path(promotion, promotion_action), params: {
        promotion_rule: {type: "SolidusFriendlyPromotions::Rules::Product"}
      }
      expect(response).to redirect_to("/admin/login")
    end
  end
end
