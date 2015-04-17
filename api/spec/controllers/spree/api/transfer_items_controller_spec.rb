
require 'spec_helper'

module Spree
  describe Api::TransferItemsController do
    render_views

    let!(:stock_transfer) { create(:stock_transfer_with_items) }
    let(:transfer_item)   { stock_transfer.transfer_items.first }

    before do
      stub_authentication!
    end

    context "as a normal user" do
      describe "#update" do
        it "cannot update a transfer item" do
          api_put :update, stock_transfer_id: stock_transfer.to_param, id: transfer_item.to_param
          expect(response.status).to eq 404
        end
      end

      describe "#receive" do
        it "cannot receive transfer items from a stock transfer" do
          api_post :receive, stock_transfer_id: stock_transfer.to_param, variant_id: transfer_item.variant.to_param
          expect(response.status).to eq 404
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#update" do
        subject do
          update_params = { id: transfer_item.to_param, transfer_item: { received_quantity: received_quantity } }
          api_put :update, update_params
        end

        context "valid parameters" do
          let(:received_quantity) { 2 }

          it "can update a transfer item" do
            subject
            expect(response.status).to eq 200
          end

          it "updates the transfer item" do
            expect { subject }.to change { transfer_item.reload.received_quantity }.to(2)
          end
        end

        context "invalid parameters" do
          let(:received_quantity) { -5 }

          it "returns a 422" do
            subject
            expect(response.status).to eq 422
          end

          it "does not update the transfer item" do
            expect { subject }.to_not change { transfer_item.reload.received_quantity }
          end
        end
      end

      describe "#receive" do
        subject do
          api_post :receive, stock_transfer_id: stock_transfer.to_param, variant_id: variant_id
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

          it "returns a 404" do
            subject
            expect(response.status).to eq 404
          end
        end
      end
    end
  end
end
