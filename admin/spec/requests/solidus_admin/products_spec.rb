# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::PropertiesController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "PATCH #update" do
    let(:product) { create(:product) }
    let(:params) do
      {
        name: "T-Shirt",
        description: "Nice T-Shirt",
        slug: "nice-t-shirt",
        meta_title: "Nice T-Shirt",
        meta_description: "It is a really nice T-Shirt",
        meta_keywords: "tshirt, tee",
        gtin: "12345",
        condition: "new",
        price: 100,
        cost_price: 100,
        cost_currency: "USD",
        sku: "T123",
        shipping_category_id: create(:shipping_category).id,
        tax_category_id: create(:tax_category).id,
        available_on: "2025-05-28".to_date,
        discontinue_on: "2026-01-06".to_date,
        promotionable: true,
        option_type_ids: [create(:option_type).id, create(:option_type).id],
        taxon_ids: [create(:taxon).id, create(:taxon).id],
      }
    end

    it "updates product" do
      patch solidus_admin.product_path(product), params: { product: params }
      expect(response).to have_http_status(:see_other)
      expect(product.reload).to have_attributes(params.except(Spree::Product::MASTER_ATTRIBUTES))
      %i[gtin condition price cost_price cost_currency sku].each do |attr|
        expect(product.public_send(attr)).to eq(params[attr])
      end
    end
  end
end
