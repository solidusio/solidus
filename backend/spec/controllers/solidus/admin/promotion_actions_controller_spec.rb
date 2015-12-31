require 'spec_helper'

describe Solidus::Admin::PromotionActionsController, :type => :controller do
  stub_authorization!

  let!(:promotion) { create(:promotion) }

  it "can create a promotion action of a valid type" do
    spree_post :create, :promotion_id => promotion.id, :action_type => "Solidus::Promotion::Actions::CreateAdjustment"
    expect(response).to be_redirect
    expect(response).to redirect_to spree.edit_admin_promotion_path(promotion)
    expect(promotion.actions.count).to eq(1)
  end

  it "can not create a promotion action of an invalid type" do
    spree_post :create, :promotion_id => promotion.id, :action_type => "Solidus::InvalidType"
    expect(response).to be_redirect
    expect(response).to redirect_to spree.edit_admin_promotion_path(promotion)
    expect(promotion.rules.count).to eq(0)
  end
end
