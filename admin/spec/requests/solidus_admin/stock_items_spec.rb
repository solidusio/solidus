# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::StockItemsController", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #index" do
    it "loads stock item stock locations in a single query" do
      3.times do
        location = create(:stock_location, propagate_all_variants: false)
        create(:stock_item, stock_location: location, variant: create(:variant))
      end

      expect { get solidus_admin.stock_items_path }.to make_database_queries(matching: /from .spree_stock_locations./i, count: 2)
    end
  end

  context "with stock management restricted to a stock location" do
    let(:admin_user) { create(:user, spree_roles: [role], stock_locations: [assigned_location]) }
    let(:role) { create(:role, name: "warehouse") }
    let(:assigned_location) { create(:stock_location, name: "Assigned warehouse", propagate_all_variants: false) }
    let(:other_location) { create(:stock_location, name: "Other warehouse", propagate_all_variants: false) }
    let(:variant) { create(:variant) }
    let!(:assigned_item) { create(:stock_item, stock_location: assigned_location, variant:) }
    let!(:other_item) { create(:stock_item, stock_location: other_location, variant:, backorderable: true) }

    before do
      Spree::Config.roles.assign_permissions "warehouse", ["Spree::PermissionSets::RestrictedStockManagement"]
    end

    after { Spree::Config.roles.roles.delete("warehouse") }

    it "lists only the stock items the user can read" do
      other_location.update!(active: false)

      get solidus_admin.stock_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(solidus_admin.edit_stock_item_path(assigned_item))
      expect(response.body).not_to include(solidus_admin.edit_stock_item_path(other_item))
    end

    it "updates a stock item of the assigned stock location" do
      get solidus_admin.edit_stock_item_path(assigned_item)
      expect(response).to have_http_status(:ok)

      expect {
        patch solidus_admin.stock_item_path(assigned_item), params: {quantity_adjustment: 5, stock_item: {backorderable: false}}
      }.to change { assigned_item.reload.count_on_hand }.by(5)
    end

    it "forbids editing a stock item of another stock location" do
      get solidus_admin.edit_stock_item_path(other_item)

      expect(response).to have_http_status(:forbidden)
      expect(response.body).not_to include("Other warehouse")
    end

    it "forbids updating a stock item of another stock location" do
      expect {
        patch solidus_admin.stock_item_path(other_item), params: {quantity_adjustment: 5, stock_item: {backorderable: false}}
      }.not_to change { other_item.reload.attributes.slice("count_on_hand", "backorderable") }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
