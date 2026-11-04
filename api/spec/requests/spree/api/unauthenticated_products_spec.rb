# frozen_string_literal: true

require "shared_examples/protect_product_actions"
require "spec_helper"

module Spree::Api
  describe "Unauthorized products", type: :request do
    let!(:product) { create(:product) }
    let(:attributes) { [:id, :name, :description, :price, :available_on, :slug, :meta_description, :meta_keywords, :taxon_ids, :meta_title] }

    context "without authentication" do
      before do
        stub_spree_preferences(Spree::Api::Config, requires_authentication: false)
      end

      it "retrieves a list of products" do
        get spree.api_products_path
        expect(json_response["products"].first).to have_attributes(attributes)
        expect(json_response["count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      it "allows shared caches to store the product list" do
        get spree.api_products_path
        expect(response.headers["Cache-Control"]).to eq "max-age=900, public"
        expect(response.headers["Surrogate-Control"]).to eq "max-age=900"
        expect(response.headers["Surrogate-Key"]).to be_nil
      end

      it "allows shared caches to store a single product" do
        other_product = create(:product)
        get spree.api_product_path(other_product)
        expect(response.headers["Cache-Control"]).to eq "max-age=900, public"
        expect(response.headers["Surrogate-Control"]).to eq "max-age=900"
        expect(response.headers["Surrogate-Key"]).to eq "product_id=#{other_product.id}"
      end

      it_behaves_like "modifying product actions are restricted"
    end
  end
end
