# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::PromotionCodesController do
  stub_authorization!
  render_views

  let!(:promotion) { create(:promotion) }
  let!(:code1) { create(:promotion_code, promotion: promotion) }
  let!(:code2) { create(:promotion_code, promotion: promotion) }
  let!(:code3) { create(:promotion_code, promotion: promotion) }

  it "can create a CSV file with all promotion codes" do
    get :index, params: { promotion_id: promotion.id, format: 'csv' }
    expect(response).to be_successful
    parsed = CSV.parse(response.body, headers: true)
    expect(parsed.entries.map(&:to_h)).to eq([{ "Code" => code1.value }, { "Code" => code2.value }, { "Code" => code3.value }])
  end

  it "can create a new code" do
    post :create, params: { promotion_id: promotion.id, promotion_code: { value: "new_code" } }
    expect(response).to redirect_to(spree.admin_promotion_promotion_codes_path(promotion))
    expect(Spree::PromotionCode.where(promotion: promotion).count).to eql(4)
  end

  it "cannot create an existing code" do
    post :create, params: { promotion_id: promotion.id, promotion_code: { value: code1.value } }
    expect(flash[:error]).not_to be_nil
    expect(Spree::PromotionCode.where(promotion: promotion).count).to eql(3)
  end

  it "can't create a new code on promotions that apply automatically" do
    apply_automatically_promotion = create(:promotion, apply_automatically: true)
    get :new, params: { promotion_id: apply_automatically_promotion.id }
    expect(response).to redirect_to(spree.admin_promotion_promotion_codes_path(apply_automatically_promotion))
    expect(flash[:error]).not_to be_nil
  end
end
