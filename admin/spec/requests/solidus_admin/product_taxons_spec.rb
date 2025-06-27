# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::ProductTaxonsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let!(:product) { create(:product) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_product_taxon_path(product)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "when taxon belongs to a parent" do
      context "with valid parameters" do
        let!(:parent_taxon) { create(:taxonomy).root }
        let(:valid_attributes) { { name: "Accessories", parent_id: parent_taxon.id } }

        it "creates new taxon and new classification" do
          expect(Spree::Taxon.count).to eq(1)
          expect(product.classifications.count).to eq(0)

          post solidus_admin.product_taxons_path(product), params: { taxon: valid_attributes }

          expect(Spree::Taxon.count).to eq(2)
          expect(product.classifications.count).to eq(1)
        end

        it "redirects with a 303 See Other status" do
          post solidus_admin.product_taxons_path(product), params: { taxon: valid_attributes }
          expect(response).to redirect_to(solidus_admin.product_path(product))
          expect(response).to have_http_status(:see_other)
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) { { name: "" } }

        it "does not create a new taxon" do
          expect {
            post solidus_admin.product_taxons_path(product), params: { taxon: invalid_attributes }
          }.not_to change(Spree::Taxon, :count)
        end

        it "returns unprocessable_entity status" do
          post solidus_admin.product_taxons_path(product), params: { taxon: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when taxon is a root" do
      context "with valid parameters" do
        let(:valid_attributes) { { name: "Accessories", parent_id: nil } }

        it "creates new taxonomy, new root taxon and new classification" do
          expect(Spree::Taxonomy.count).to eq(0)
          expect(Spree::Taxon.count).to eq(0)
          expect(product.classifications.count).to eq(0)

          post solidus_admin.product_taxons_path(product), params: { taxon: valid_attributes }

          expect(Spree::Taxonomy.count).to eq(1)
          expect(Spree::Taxon.count).to eq(1)
          expect(product.classifications.count).to eq(1)
        end

        it "redirects with a 303 See Other status" do
          post solidus_admin.product_taxons_path(product), params: { taxon: valid_attributes }
          expect(response).to redirect_to(solidus_admin.product_path(product))
          expect(response).to have_http_status(:see_other)
        end
      end

      context "with invalid parameters" do
        let!(:another_root_taxon) { create(:taxonomy, name: "Apparel").root }
        let(:invalid_attributes) { { name: another_root_taxon.name, parent_id: nil } }

        it "does not create new records" do
          expect(Spree::Taxonomy.count).to eq(1)
          expect(Spree::Taxon.count).to eq(1)
          expect(product.classifications.count).to eq(0)

          post solidus_admin.product_taxons_path(product), params: { taxon: invalid_attributes }

          expect(Spree::Taxonomy.count).to eq(1)
          expect(Spree::Taxon.count).to eq(1)
          expect(product.classifications.count).to eq(0)
        end

        it "returns unprocessable_entity status" do
          post solidus_admin.product_taxons_path(product), params: { taxon: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
