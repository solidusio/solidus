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

        before { expect(controller).to receive(:spree_current_user).and_return(user) }
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
        let!(:product_1) { create(:product) }
        let!(:product_2) { create(:product) }
        let!(:variant_3) { create(:variant, product: product_2) }
        let!(:variant_4) { create(:variant, product: product_2) }

        context "with product_slug param" do
          it "scopes the variants by the product" do
            get :index, params: { product_slug: variant_1.product.slug }
            expect(assigns(:variants)).to contain_exactly(variant_1)
          end

          context "when a product with no variants is requested" do
            it "returns the master variant of the product" do
              get :index, params: { product_slug: product_1.slug }
              expect(assigns(:variants)).to contain_exactly(product_1.master)
            end
          end

          context "when a product with variants is requested" do
            it "returns only the variants of the product" do
              get :index, params: { product_slug: product_2.slug }
              expect(assigns(:variants)).to contain_exactly(variant_3, variant_4)
            end
          end
        end

        context "without product_slug params" do
          it "allows all accessible variants to be returned" do
            get :index
            expect(assigns(:variants)).to contain_exactly(
              variant_1,
              variant_1.product.master,
              variant_2,
              variant_2.product.master,
              product_1.master,
              product_2.master,
              variant_3,
              variant_4
            )
          end
        end
      end
    end
  end
end

