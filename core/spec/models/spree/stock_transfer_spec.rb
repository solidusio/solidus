require 'spec_helper'

module Spree
  describe StockTransfer, type: :model do
    let(:destination_location) { create(:stock_location_with_items) }
    let(:source_location) { create(:stock_location_with_items) }
    let(:stock_item) { source_location.stock_items.order(:id).first }
    let(:variant) { stock_item.variant }
    let(:stock_transfer) do
      StockTransfer.create(description: 'PO123', source_location: source_location, destination_location: destination_location)
    end

    subject { stock_transfer }

    describe '#description' do
      subject { super().description }
      it { is_expected.to eq 'PO123' }
    end

    describe '#to_param' do
      subject { super().to_param }
      it { is_expected.to match /T\d+/ }
    end

    describe "transfer item building" do
      let(:stock_transfer) do
        variant = source_location.stock_items.first.variant
        stock_transfer = Spree::StockTransfer.new(
          number: "T123",
          source_location: source_location,
          destination_location: destination_location
        )
        stock_transfer.transfer_items.build(variant: variant, expected_quantity: 5)
        stock_transfer
      end

      subject { stock_transfer.save }

      it { is_expected.to eq true }

      it "creates the associated transfer item" do
        expect { subject }.to change { Spree::TransferItem.count }.by(1)
      end
    end

    describe "#receivable?" do
      subject { stock_transfer.receivable? }

      context "finalized" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "shipped" do
        before do
          stock_transfer.update_attributes(shipped_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "closed" do
        before do
          stock_transfer.update_attributes(closed_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "finalized and closed" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.current, closed_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "shipped and closed" do
        before do
          stock_transfer.update_attributes(shipped_at: Time.current, closed_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "finalized and shipped" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.current, shipped_at: Time.current)
        end

        it { is_expected.to eq true }
      end
    end

    describe "#finalizable?" do
      subject { stock_transfer.finalizable? }

      context "finalized" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "shipped" do
        before do
          stock_transfer.update_attributes(shipped_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "closed" do
        before do
          stock_transfer.update_attributes(closed_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "finalized and closed" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.current, closed_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "shipped and closed" do
        before do
          stock_transfer.update_attributes(shipped_at: Time.current, closed_at: Time.current)
        end

        it { is_expected.to eq false }
      end

      context "no action taken on stock transfer" do
        before do
          stock_transfer.update_attributes(finalized_at: nil, shipped_at: nil, closed_at: nil)
        end

        it { is_expected.to eq true }
      end
    end

    describe "#finalize" do
      let(:user) { create(:user) }

      subject { stock_transfer.finalize(user) }

      context "can be finalized" do
        it "sets a finalized_at date" do
          expect { subject }.to change { stock_transfer.finalized_at }
        end

        it "sets the finalized_by to the supplied user" do
          subject
          expect(stock_transfer.finalized_by).to eq user
        end
      end

      context "can't be finalized" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.current)
        end

        it "doesn't set a finalized_at date" do
          expect { subject }.to_not change { stock_transfer.finalized_at }
        end

        it "doesn't set a finalized_by user" do
          expect { subject }.to_not change { stock_transfer.finalized_by }
        end

        it "adds an error message" do
          subject
          expect(stock_transfer.errors.full_messages).to include Spree.t(:stock_transfer_cannot_be_finalized)
        end
      end
    end

    describe "#close" do
      let(:user) { create(:user) }
      let(:stock_transfer) { create(:receivable_stock_transfer_with_items) }

      subject { stock_transfer.close(user) }

      context "can be closed" do
        it "sets a closed_at date" do
          expect { subject }.to change { stock_transfer.closed_at }
        end

        it "sets the closed_by to the supplied user" do
          subject
          expect(stock_transfer.closed_by).to eq user
        end
      end

      context "can't be closed" do
        before do
          stock_transfer.update_attributes(finalized_at: nil)
        end

        it "doesn't set a closed_at date" do
          expect { subject }.to_not change { stock_transfer.closed_at }
        end

        it "doesn't set a closed_by user" do
          expect { subject }.to_not change { stock_transfer.closed_by }
        end

        it "adds an error message" do
          subject
          expect(stock_transfer.errors.full_messages).to include Spree.t(:stock_transfer_must_be_receivable)
        end
      end
    end

    describe "destroying" do
      subject { stock_transfer.destroy }

      context "stock transfer is finalized" do
        before do
          stock_transfer.update_attributes!(finalized_at: Time.current)
        end

        it "doesn't destroy the stock transfer" do
          expect { subject }.to_not change { Spree::StockTransfer.count }
        end

        it "adds an error message to the model" do
          subject
          expect(stock_transfer.errors.full_messages).to include Spree.t('errors.messages.cannot_delete_finalized_stock_transfer')
        end
      end

      context "stock transfer is not finalized" do
        before do
          stock_transfer.update_attributes!(finalized_at: nil)
        end

        it "destroys the stock transfer" do
          expect { subject }.to change { Spree::StockTransfer.count }.by(-1)
        end
      end
    end

    describe '#ship' do
      let(:stock_transfer) { create(:stock_transfer, tracking_number: "ABC123") }

      context "tracking number is provided" do
        subject { stock_transfer.ship(tracking_number: "XYZ123") }

        it "updates the tracking number" do
          expect { subject }.to change { stock_transfer.tracking_number }.from("ABC123").to("XYZ123")
        end
      end

      context "tracking number is not provided" do
        subject { stock_transfer.ship }

        it "preserves the existing tracking number" do
          expect { subject }.to_not change { stock_transfer.tracking_number }.from("ABC123")
        end
      end
    end

    describe '#transfer' do
      let(:stock_transfer) { create(:stock_transfer_with_items) }

      before do
        stock_transfer.transfer_items.each { |item| item.update_attributes(expected_quantity: 1) }
      end

      subject { stock_transfer.transfer }

      context 'with enough stock' do
        it 'creates stock movements for transfer items' do
          expect{ subject }.to change{ Spree::StockMovement.count }.by(stock_transfer.transfer_items.count)
        end
      end

      context 'without enough stock' do
        before do
          stockless_variant = stock_transfer.transfer_items.last.variant
          stock_transfer.source_location.stock_item(stockless_variant).set_count_on_hand(0)
        end

        it 'rollsback the transaction' do
          expect{ subject }.to_not change{ Spree::StockMovement.count }
        end

        it 'adds errors' do
          subject
          expect(stock_transfer.errors.full_messages.join(', ')).to match /not enough inventory/
        end

        it 'returns false' do
          expect(subject).to eq false
        end
      end
    end
  end
end
