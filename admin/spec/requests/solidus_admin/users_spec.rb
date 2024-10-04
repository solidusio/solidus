# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::UsersController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get solidus_admin.users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get solidus_admin.edit_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /destroy" do
    it "deletes the user and redirects to the index page with a 303 See Other status" do
      # Ensure the user exists prior to deletion
      user

      expect {
        delete solidus_admin.user_path(user)
      }.to change(Spree.user_class, :count).by(-1)

      expect(response).to redirect_to(solidus_admin.users_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete solidus_admin.user_path(user)
      follow_redirect!
      expect(response.body).to include("Users were successfully removed.")
    end
  end

  describe "search functionality" do
    before do
      create(:user, email: "test@example.com")
      create(:user, email: "another@example.com")
    end

    it "filters users based on search parameters" do
      get solidus_admin.users_path, params: { q: { email_cont: "test" } }
      expect(response.body).to include("test@example.com")
      expect(response.body).not_to include("another@example.com")
    end
  end
end
