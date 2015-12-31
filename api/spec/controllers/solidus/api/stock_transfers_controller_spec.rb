require 'spec_helper'

module Spree
  describe Api::StockTransfersController do
    render_views

    let!(:stock_transfer) { create(:stock_transfer_with_items) }
    let(:transfer_item)   { stock_transfer.transfer_items.first }

    before do
      stub_authentication!
    end

    context "as a normal user" do
      describe "#receive" do
        it "cannot receive transfer items from a stock transfer" do
          api_post :receive, id: stock_transfer.to_param, variant_id: transfer_item.variant.to_param
          expect(response.status).to eq 401
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#receive" do
        subject do
          api_post :receive, id: stock_transfer.to_param, variant_id: variant_id
        end

        context "valid parameters" do
          let(:variant_id) { transfer_item.variant.to_param }

          it "can receive a transfer items from a stock transfer" do
            subject
            expect(response.status).to eq 200
          end

          it "increments the received quantity for the transfer_item" do
            expect { subject }.to change { transfer_item.reload.received_quantity }.by(1)
          end

          it "returns the received transfer item in the response" do
            subject
            expect(JSON.parse(response.body)["received_item"]["id"]).to eq transfer_item.id
          end
        end

        context "transfer item does not have stock in source location after ship" do
          let(:variant_id) { transfer_item.variant.to_param }
          let(:user) { create :user }

          before do
            stock_transfer.finalize(user)
            stock_transfer.ship(shipped_at: Time.current)
            stock_transfer.source_location.stock_item(transfer_item.variant_id).set_count_on_hand(0)
          end

          it "can still receive item" do
            expect { subject }.to change { transfer_item.reload.received_quantity }.by(1)
          end
        end

        context "transfer item has been fully received" do
          let(:variant_id) { transfer_item.variant.to_param }

          before do
            transfer_item.update_attributes!(expected_quantity: 1, received_quantity: 1)
          end

          it "returns a 422" do
            subject
            expect(response.status).to eq 422
          end

          it "returns a specific error message" do
            subject
            expect(JSON.parse(response.body)["errors"]["received_quantity"]).to eq ["must be less than or equal to 1"]
          end
        end

        context "variant is not in the transfer order" do
          let(:variant_id) { create(:variant).to_param }

          it "returns a 422" do
            subject
            expect(response.status).to eq 422
          end

          it "returns a specific error message" do
            subject
            expect(JSON.parse(response.body)["error"]).to eq Spree.t(:item_not_in_stock_transfer)
          end
        end
      end
    end
  end
end
