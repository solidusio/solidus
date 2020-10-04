# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Admin
    describe StockItemsController, type: :controller do
      stub_authorization!

      describe "#create" do
        let!(:variant) { create(:variant) }
        let!(:stock_location) { variant.stock_locations.first }
        let(:stock_item) { variant.stock_items.first }
        let!(:user) { create :user }

        before { expect(controller).to receive(:try_spree_current_user).and_return(user) }
        before { request.env["HTTP_REFERER"] = "product_admin_page" }

        subject do
          post :create, params: { variant_id: variant, stock_location_id: stock_location, stock_movement: { quantity: 1, stock_item_id: stock_item.id } }
        end

        it "creates a stock movement with originator" do
          expect { subject }.to change { Spree::StockMovement.count }.by(1)
          stock_movement = Spree::StockMovement.last
          expect(stock_movement.originator_type).to eq "Spree::LegacyUser"
        end
      end

      describe "#index" do
        let!(:variant_1) { create(:variant) }
        let!(:variant_2) { create(:variant) }

        context "with product_slug param" do
          it "scopes the variants by the product" do
            get :index, params: { product_slug: variant_1.product.slug }
            expect(assigns(:variants)).to include variant_1
            expect(assigns(:variants)).not_to include variant_2
          end
        end

        context "without product_slug params" do
          it "allows all accessible variants to be returned" do
            get :index
            expect(assigns(:variants)).to include variant_1
            expect(assigns(:variants)).to include variant_2
          end
        end
      end
    end
  end
end
