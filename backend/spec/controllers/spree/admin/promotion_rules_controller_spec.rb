# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::PromotionRulesController, type: :controller do
  let!(:promotion) { create(:promotion) }

  context "when the user is authorized" do
    stub_authorization! do |_u|
      Spree::PermissionSets::PromotionManagement.new(self).activate!
    end

    it "can create a promotion rule of a valid type" do
      post :create, params: { promotion_id: promotion.id, promotion_rule: { type: "Spree::Promotion::Rules::Product" } }
      expect(response).to be_redirect
      expect(response).to redirect_to spree.edit_admin_promotion_path(promotion)
      expect(promotion.rules.count).to eq(1)
    end

    it "can not create a promotion rule of an invalid type" do
      post :create, params: { promotion_id: promotion.id, promotion_rule: { type: "Spree::InvalidType" } }
      expect(response).to be_redirect
      expect(response).to redirect_to spree.edit_admin_promotion_path(promotion)
      expect(promotion.rules.count).to eq(0)
    end
  end

  context "when the user is not authorized" do
    it "sets an error message and redirects the user" do
      post :create, params: { promotion_id: promotion.id, promotion_rule: { type: "Spree::Promotion::Rules::Product" } }

      expect(flash[:error]).to eq("Authorization Failure")
      expect(response).to redirect_to('/unauthorized')
    end
  end
end
