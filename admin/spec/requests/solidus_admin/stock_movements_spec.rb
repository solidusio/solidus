# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::StockMovementsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:stock_location) { create(:stock_location, propagate_all_variants: false) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET #index" do
    it "renders the stock movements of the stock location" do
      stock_item = create(:stock_item, stock_location:, variant: create(:variant, sku: "MOVED-SKU"))
      create(:stock_movement, stock_item:, quantity: 5)

      get solidus_admin.stock_location_stock_movements_path(stock_location)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MOVED-SKU")
    end

    context "with stock management restricted to a stock location" do
      let(:admin_user) { create(:user, spree_roles: [role], stock_locations: [assigned_location]) }
      let(:role) { create(:role, name: "warehouse") }
      let(:assigned_location) { create(:stock_location, propagate_all_variants: false) }

      before do
        Spree::Config.roles.assign_permissions "warehouse", ["Spree::PermissionSets::RestrictedStockManagement"]
      end

      after { Spree::Config.roles.roles.delete("warehouse") }

      it "forbids listing stock movements" do
        get solidus_admin.stock_location_stock_movements_path(assigned_location)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
