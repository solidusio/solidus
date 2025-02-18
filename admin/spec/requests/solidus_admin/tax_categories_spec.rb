# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

RSpec.describe "SolidusAdmin::TaxCategoriesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:tax_category) { create(:tax_category) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.tax_categories_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_tax_category_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Valid" } }

      it "creates a new TaxCategory" do
        expect {
          post solidus_admin.tax_categories_path, params: { tax_category: valid_attributes }
        }.to change(Spree::TaxCategory, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.tax_categories_path, params: { tax_category: valid_attributes }
        expect(response).to redirect_to(solidus_admin.tax_categories_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.tax_categories_path, params: { tax_category: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Tax category was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not create a new TaxCategory" do
        expect {
          post solidus_admin.tax_categories_path, params: { tax_category: invalid_attributes }
        }.not_to change(Spree::TaxCategory, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.tax_categories_path, params: { tax_category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_tax_category_path(tax_category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Updated Tax Category" } }

      it "updates the tax category" do
        patch solidus_admin.tax_category_path(tax_category), params: { tax_category: valid_attributes }
        tax_category.reload
        expect(tax_category.name).to eq("Updated Tax Category")
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.tax_category_path(tax_category), params: { tax_category: valid_attributes }
        expect(response).to redirect_to(solidus_admin.tax_categories_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.tax_category_path(tax_category), params: { tax_category: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Tax category was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not update the tax category" do
        original_name = tax_category.name
        patch solidus_admin.tax_category_path(tax_category), params: { tax_category: invalid_attributes }
        tax_category.reload
        expect(tax_category.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.tax_category_path(tax_category), params: { tax_category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the tax category and redirects to the index page with a 303 See Other status" do
      # Ensure the tax_category exists before deletion
      tax_category

      expect {
        delete solidus_admin.tax_category_path(tax_category)
      }.to change(Spree::TaxCategory, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.tax_categories_path)
      expect(response).to have_http_status(:see_other)
    end

    include_examples 'request: bulk delete resources' do
      let(:resource_factory) { :tax_category }
      let(:bulk_delete_path) { ->(ids) { solidus_admin.tax_categories_path(id: ids) } }
      let(:resource_class) { Spree::TaxCategory }
      let(:redirect_path) { solidus_admin.tax_categories_path }
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.tax_category_path(tax_category)
      follow_redirect!
      expect(response.body).to include("Tax categories were successfully removed.")
    end
  end
end
