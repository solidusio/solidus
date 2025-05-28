# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::UsersController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user_with_addresses) }
  let(:address) { create(:address) }

  let(:valid_address_params) do
    {
      user: {
        bill_address_attributes: {
          name: address.name,
          address1: address.address1,
          address2: address.address2,
          city: address.city,
          zipcode: address.zipcode,
          state_id: address.state_id,
          country_id: address.country_id,
          phone: address.phone
        }
      }
    }
  end

  # Invalid due to missing "name" field.
  let(:invalid_address_params) do
    {
      user: {
        bill_address_attributes: {
          address1: address.address1,
          address2: address.address2,
          city: address.city,
          zipcode: address.zipcode,
          state_id: address.state_id,
          country_id: address.country_id,
          phone: address.phone
        }
      }
    }
  end

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

  describe "GET /orders" do
    let!(:order) { create(:order, user: user) }

    it "renders the orders template and displays the user's orders" do
      get solidus_admin.orders_user_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(order.number)
    end
  end

  describe "GET /items" do
    let!(:order) { create(:order_with_line_items, user: user) }

    it "renders the items template and displays the user's purchased items" do
      get solidus_admin.items_user_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(order.number)
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

  describe "GET /addresses" do
    it "renders the addresses template with a 200 OK status" do
      get solidus_admin.addresses_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT /update_addresses" do
    context "with valid address parameters" do
      it "updates the user's address and redirects with a success message" do
        put solidus_admin.update_addresses_user_path(user), params: valid_address_params
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Address has been successfully updated.")
      end
    end

    context "with invalid address parameters" do
      it "does not update the user's address and renders the addresses component with errors" do
        put solidus_admin.update_addresses_user_path(user), params: invalid_address_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "search functionality" do
    before do
      create(:user, email: "test@example.com")
      create(:user, email: "another@example.com")
    end

    it "filters users based on search parameters" do
      get solidus_admin.users_path, params: {q: {email_cont: "test"}}
      expect(response.body).to include("test@example.com")
      expect(response.body).not_to include("another@example.com")
    end
  end
end
