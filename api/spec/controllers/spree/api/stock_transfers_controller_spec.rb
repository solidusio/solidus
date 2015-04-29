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
          api_post :receive, stock_transfer_id: stock_transfer.to_param, variant_id: transfer_item.variant.to_param
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
