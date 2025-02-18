# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

RSpec.describe "SolidusAdmin::RolesController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:role) { create(:role) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
    Spree::Role.find_or_create_by(name: 'admin')
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.roles_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get solidus_admin.new_role_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Customer", description: "A person who buys stuff" } }

      it "creates a new Role" do
        expect {
          post solidus_admin.roles_path, params: { role: valid_attributes }
        }.to change(Spree::Role, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post solidus_admin.roles_path, params: { role: valid_attributes }
        expect(response).to redirect_to(solidus_admin.roles_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post solidus_admin.roles_path, params: { role: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Role was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not create a new Role" do
        expect {
          post solidus_admin.roles_path, params: { role: invalid_attributes }
        }.not_to change(Spree::Role, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post solidus_admin.roles_path, params: { role: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_role_path(role)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Publisher", description: "A person who publishes stuff" } }

      it "updates the role" do
        patch solidus_admin.role_path(role), params: { role: valid_attributes }
        role.reload
        expect(role.name).to eq("Publisher")
      end

      it "redirects to the index page with a 303 See Other status" do
        patch solidus_admin.role_path(role), params: { role: valid_attributes }
        expect(response).to redirect_to(solidus_admin.roles_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch solidus_admin.role_path(role), params: { role: valid_attributes }
        follow_redirect!
        expect(response.body).to include("Role was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "" } }

      it "does not update the role" do
        original_name = role.name
        patch solidus_admin.role_path(role), params: { role: invalid_attributes }
        role.reload
        expect(role.name).to eq(original_name)
      end

      it "renders the edit template with unprocessable_entity status" do
        patch solidus_admin.role_path(role), params: { role: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:role_to_delete) { create(:role) }

    it "deletes the role and redirects to the index page with a 303 See Other status" do
      expect {
        delete solidus_admin.role_path(role_to_delete)
      }.to change(Spree::Role, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.roles_path)
      expect(response).to have_http_status(:see_other)
    end

    include_examples 'request: bulk delete resources' do
      let(:resource_factory) { :role }
      let(:bulk_delete_path) { ->(ids) { solidus_admin.roles_path(id: ids) } }
      let(:resource_class) { Spree::Role }
      let(:redirect_path) { solidus_admin.roles_path }
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.role_path(role_to_delete)
      follow_redirect!
      expect(response.body).to include("Roles were successfully removed.")
    end
  end
end
