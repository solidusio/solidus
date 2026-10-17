# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::ProductsController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?).and_return(true)
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #index" do
    before { create_list(:product, 3) }

    it "renders successfully" do
      get solidus_admin.products_path
      expect(response).to have_http_status(:ok)
    end

    it "loads stock for every product without an N+1" do
      expect { get solidus_admin.products_path }
        .to make_database_queries(matching: /from .spree_stock_items./i, count: 1)
    end
  end

  describe "GET #new" do
    it "renders successfully" do
      get solidus_admin.new_product_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    let(:params) do
      {
        name: "T-Shirt",
        description: "Nice T-Shirt",
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
        taxon_ids: [create(:taxon).id, create(:taxon).id]
      }
    end

    it "creates a product and redirects to the product page" do
      expect {
        post solidus_admin.products_path, params: {product: params}
      }.to change(Spree::Product, :count).by(1)

      product = Spree::Product.last
      expect(response).to redirect_to(solidus_admin.product_path(product))
      expect(product).to have_attributes(params.except(Spree::Product::MASTER_ATTRIBUTES))
      %i[gtin condition price cost_price cost_currency sku].each do |attr|
        expect(product.public_send(attr)).to eq(params[attr])
      end
    end

    it "re-renders the form with unprocessable entity on invalid params" do
      post solidus_admin.products_path, params: {product: {name: ""}}
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "generates the slug from the product name" do
      post solidus_admin.products_path, params: {product: params}

      expect(Spree::Product.last.slug).to eq("t-shirt")
    end

    it "ignores a submitted slug, since it is not fillable at creation time" do
      post solidus_admin.products_path, params: {product: params.merge(slug: "custom-slug")}

      expect(Spree::Product.last.slug).to eq("t-shirt")
    end

    it "ignores a blank submitted slug" do
      post solidus_admin.products_path, params: {product: params.merge(slug: "")}

      expect(response).to have_http_status(:see_other)
      expect(Spree::Product.last.slug).to eq("t-shirt")
    end
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
        taxon_ids: [create(:taxon).id, create(:taxon).id]
      }
    end

    it "updates product" do
      patch solidus_admin.product_path(product), params: {product: params}
      expect(response).to have_http_status(:see_other)
      expect(product.reload).to have_attributes(params.except(Spree::Product::MASTER_ATTRIBUTES))
      %i[gtin condition price cost_price cost_currency sku].each do |attr|
        expect(product.public_send(attr)).to eq(params[attr])
      end
    end
  end
end
