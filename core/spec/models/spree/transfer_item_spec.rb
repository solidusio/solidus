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
        it { is_expected.to be_valid }
      end

      context "expected quantity is larger than the received quantity" do
        let(:expected_quantity) { 3 }
        let(:received_quantity) { 1 }
        it { is_expected.to be_valid }
      end

      context "expected quantity is lower than the received quantity" do
        let(:expected_quantity) { 1 }
        let(:received_quantity) { 3 }
        it { is_expected.to_not be_valid }
      end
    end

    describe "numericality" do
      context "expected_quantity is less than 0" do
        let(:expected_quantity) { -1 }
        let(:received_quantity) { 3 }
        it { is_expected.to_not be_valid }
      end

      context "received_quantity is less than 0" do
        let(:expected_quantity) { 1 }
        let(:received_quantity) { -3 }
        it { is_expected.to_not be_valid }
      end
    end

    describe "availability" do
      let(:stock_item) do
        transfer_item.variant.stock_items.find_by(stock_location: stock_transfer.source_location)
      end
      let(:expected_quantity) { 1 }
      let(:received_quantity) { 1 }

      subject { transfer_item.valid? }

      shared_examples_for 'availability check fails' do
        it "validates the availability" do
          subject
          expect(transfer_item.errors.full_messages).to include Spree.t('errors.messages.transfer_item_insufficient_stock')
        end
      end

      shared_examples_for 'availability check passes' do
        it "doesn't validate the availability" do
          subject
          expect(transfer_item.errors.full_messages).to_not include Spree.t('errors.messages.transfer_item_insufficient_stock')
        end
      end

      context "transfer order is closed" do
        before do
          stock_transfer.update_attributes!(closed_at: Time.now)
        end

        context "variant is not available" do
          before do
            stock_item.set_count_on_hand(0)
          end
          include_examples 'availability check passes'
        end

        context "variant available" do
          before do
            stock_item.set_count_on_hand(transfer_item.expected_quantity)
          end
          include_examples 'availability check passes'
        end

        context "variant does not exist in stock location" do
          before do
            stock_item.destroy
          end
          include_examples 'availability check passes'
        end
      end

      context "transfer order isn't closed" do
        before do
          stock_transfer.update_attributes!(closed_at: nil)
        end

        context "variant is not available" do
          before do
            stock_item.set_count_on_hand(0)
          end
          include_examples 'availability check fails'
        end

        context "variant available" do
          before do
            stock_item.set_count_on_hand(transfer_item.expected_quantity)
          end
          include_examples 'availability check passes'
        end

        context "variant does not exist in stock location" do
          before do
            stock_item.destroy
          end
          include_examples 'availability check fails'
        end
      end
    end
  end

  describe "received stock transfer guard" do
    subject { transfer_item.reload.update_attributes(received_quantity: 2) }

    describe "closed stock transfer" do
      context "stock_transfer is not closed" do
        before do
          stock_transfer.update_attributes!(closed_at: nil)
        end

        it { is_expected.to eq true }
      end

      context "stock_transfer is closed" do
        before do
          stock_transfer.update_attributes!(closed_at: Time.now)
        end

        it { is_expected.to eq false }

        it "adds an error message" do
          subject
          expect(transfer_item.errors.full_messages).to include Spree.t('errors.messages.cannot_modify_transfer_item_closed_stock_transfer')
        end
      end
    end
  end

  describe "destroy finalized stock transfer guard" do
    subject { transfer_item.destroy }

    context "stock transfer is finalized" do
      before do
        stock_transfer.update_attributes(finalized_at: Time.now)
      end

      it "does not destroy the transfer item" do
        expect { subject }.to_not change { Spree::TransferItem.count }
      end

      it "adds an error message" do
        subject
        expect(transfer_item.errors.full_messages).to include Spree.t('errors.messages.cannot_delete_transfer_item_with_finalized_stock_transfer')
      end
    end

    context "stock transfer is not finalized" do
      before do
        stock_transfer.update_attributes(finalized_at: nil, shipped_at: nil)
      end

      it "destroys the transfer item" do
        expect { subject }.to change { Spree::TransferItem.count }.by(-1)
      end
    end
  end
end
