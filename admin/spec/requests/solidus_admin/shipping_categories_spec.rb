# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::ShippingCategoriesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:shipping_category) { create(:shipping_category) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.shipping_categories_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_shipping_category_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Express" } }

      it "creates a new ShippingCategory" do
        expect {
          post solidus_admin.shipping_categories_path, params: { shipping_category: valid_attributes }
        }.to change(Spree::ShippingCategory, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.shipping_categories_path, params: { shipping_category: valid_attributes }
        expect(response).to redirect_to(solidus_admin.shipping_categories_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.shipping_categories_path, params: { shipping_category: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Shipping category was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not create a new ShippingCategory" do
        expect {
          post solidus_admin.shipping_categories_path, params: { shipping_category: invalid_attributes }
        }.not_to change(Spree::ShippingCategory, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.shipping_categories_path, params: { shipping_category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_shipping_category_path(shipping_category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Updated Shipping Category" } }

      it "updates the shipping category" do
        patch solidus_admin.shipping_category_path(shipping_category), params: { shipping_category: valid_attributes }
        shipping_category.reload
        expect(shipping_category.name).to eq("Updated Shipping Category")
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.shipping_category_path(shipping_category), params: { shipping_category: valid_attributes }
        expect(response).to redirect_to(solidus_admin.shipping_categories_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.shipping_category_path(shipping_category), params: { shipping_category: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Shipping category was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not update the shipping category" do
        original_name = shipping_category.name
        patch solidus_admin.shipping_category_path(shipping_category), params: { shipping_category: invalid_attributes }
        shipping_category.reload
        expect(shipping_category.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.shipping_category_path(shipping_category), params: { shipping_category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the shipping category and redirects to the index page with a 303 See Other status" do
      # Ensure the shipping_category exists before deletion
      shipping_category

      expect {
        delete solidus_admin.shipping_category_path(shipping_category)
      }.to change(Spree::ShippingCategory, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.shipping_categories_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.shipping_category_path(shipping_category)
      follow_redirect!
      expect(response.body).to include("Shipping categories were successfully removed.")
    end
  end
end
