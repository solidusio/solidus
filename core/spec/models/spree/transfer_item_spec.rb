require 'spec_helper'

describe Spree::TransferItem do
  let(:stock_transfer) { create(:stock_transfer_with_items) }
  let(:transfer_item)  { stock_transfer.transfer_items.first }

  subject { transfer_item }

  describe "validation" do
    before do
      transfer_item.assign_attributes(expected_quantity: expected_quantity, received_quantity: received_quantity)
    end

    describe "expected vs received quantity" do
      context "expected quantity is the same as the received quantity" do
        let(:expected_quantity) { 1 }
        let(:received_quantity) { 1 }
        it { should be_valid }
      end

      context "expected quantity is larger than the received quantity" do
        let(:expected_quantity) { 3 }
        let(:received_quantity) { 1 }
        it { should be_valid }
      end

      context "expected quantity is lower than the received quantity" do
        let(:expected_quantity) { 1 }
        let(:received_quantity) { 3 }
        it { should_not be_valid }
      end
    end

    describe "numericality" do
      context "expected_quantity is less than 0" do
        let(:expected_quantity) { -1 }
        let(:received_quantity) { 3 }
        it { should_not be_valid }
      end

      context "received_quantity is less than 0" do
        let(:expected_quantity) { 1 }
        let(:received_quantity) { -3 }
        it { should_not be_valid }
      end
    end
  end

  describe "received stock transfer guard" do

    subject { transfer_item.update_attributes(received_quantity: 2) }

    context "stock transfer is not closed" do
      before do
        stock_transfer.update_attributes(closed_at: nil)
      end

      it "can update" do
        subject
        expect(transfer_item.reload.received_quantity).to eq 2
      end
    end

    context "stock transfer is closed" do
      before do
        stock_transfer.update_attributes(closed_at: Time.now)
      end

      it "cannot update" do
        expect { subject }.to raise_error(Spree::StockTransfer::CannotModifyClosedStockTransfer)
      end
    end
  end
end
