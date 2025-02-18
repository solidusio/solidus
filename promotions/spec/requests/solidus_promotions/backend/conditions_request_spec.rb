# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Conditions", type: :request do
  let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
  let(:benefit) { promotion.benefits.first }

  context "when the user is authorized" do
    stub_authorization! do |_u|
      SolidusPromotions::PermissionSets::PromotionManagement.new(self).activate!
    end

    it "can create a promotion condition of a valid type" do
      post solidus_promotions.admin_promotion_benefit_conditions_path(promotion, benefit), params: {
        condition: {type: "SolidusPromotions::Conditions::Product"}
      }
      expect(response).to be_redirect
      expect(response).to redirect_to solidus_promotions.edit_admin_promotion_path(promotion)
      expect(benefit.conditions.count).to eq(1)
    end

    it "can not create a promotion condition of an invalid type" do
      post solidus_promotions.admin_promotion_benefit_conditions_path(promotion, benefit), params: {
        condition: {type: "Spree::InvalidType"}
      }
      expect(response).to be_redirect
      expect(response).to redirect_to solidus_promotions.edit_admin_promotion_path(promotion)
      expect(benefit.conditions.count).to eq(0)
    end
  end

  context "when the user is not authorized" do
    it "redirects the user to login" do
      post solidus_promotions.admin_promotion_benefit_conditions_path(promotion, benefit), params: {
        condition: {type: "SolidusPromotions::Conditions::Product"}
      }
      expect(response).to be_redirect
    end
  end
end
