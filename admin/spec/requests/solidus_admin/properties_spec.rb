# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::PropertiesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:property) { create(:property) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.properties_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_property_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Material", presentation: "Material Type" } }

      it "creates a new Property" do
        expect {
          post solidus_admin.properties_path, params: { property: valid_attributes }
        }.to change(Spree::Property, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.properties_path, params: { property: valid_attributes }
        expect(response).to redirect_to(solidus_admin.properties_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.properties_path, params: { property: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Property was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", presentation: "" } }

      it "does not create a new Property" do
        expect {
          post solidus_admin.properties_path, params: { property: invalid_attributes }
        }.not_to change(Spree::Property, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.properties_path, params: { property: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_property_path(property)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Updated Name", presentation: "Updated Presentation" } }

      it "updates the property" do
        patch solidus_admin.property_path(property), params: { property: valid_attributes }
        property.reload
        expect(property.name).to eq("Updated Name")
        expect(property.presentation).to eq("Updated Presentation")
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.property_path(property), params: { property: valid_attributes }
        expect(response).to redirect_to(solidus_admin.properties_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.property_path(property), params: { property: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Property was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", presentation: "Updated Presentation" } }

      it "does not update the property" do
        original_name = property.name
        patch solidus_admin.property_path(property), params: { property: invalid_attributes }
        property.reload
        expect(property.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.property_path(property), params: { property: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the property and redirects to the index page with a 303 See Other status" do
      # Ensure the property exists before attempting to delete it.
      property

      expect {
        delete solidus_admin.property_path(property)
      }.to change(Spree::Property, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.properties_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.property_path(property)
      follow_redirect!
      expect(response.body).to include("Properties were successfully removed.")
    end
  end
end
