require 'spec_helper'

module Spree
  describe StockTransfer, :type => :model do
    let(:destination_location) { create(:stock_location_with_items) }
    let(:source_location) { create(:stock_location_with_items) }
    let(:stock_item) { source_location.stock_items.order(:id).first }
    let(:variant) { stock_item.variant }
    let(:stock_transfer) { StockTransfer.create(reference: 'PO123') }

    subject { stock_transfer }

    describe '#reference' do
      subject { super().reference }
      it { is_expected.to eq 'PO123' }
    end

    describe '#to_param' do
      subject { super().to_param }
      it { is_expected.to match /T\d+/ }
    end

    it 'transfers variants between 2 locations' do
      variants = { variant => 5 }

      subject.transfer(source_location,
                       destination_location,
                       variants)

      expect(source_location.count_on_hand(variant)).to eq 5
      expect(destination_location.count_on_hand(variant)).to eq 5

      expect(subject.source_location).to eq source_location
      expect(subject.destination_location).to eq destination_location

      expect(subject.source_movements.first.quantity).to eq -5
      expect(subject.destination_movements.first.quantity).to eq 5
    end

    it 'receive new inventory (from a vendor)' do
      variants = { variant => 5 }

      subject.receive(destination_location, variants)

      expect(destination_location.count_on_hand(variant)).to eq 5

      expect(subject.source_location).to be_nil
      expect(subject.destination_location).to eq destination_location
    end

    describe "receivable?" do
      subject { stock_transfer.receivable? }

      context "finalized" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.now)
        end

        it { is_expected.to eq false }
      end

      context "shipped" do
        before do
          stock_transfer.update_attributes(shipped_at: Time.now)
        end

        it { is_expected.to eq false }
      end

      context "closed" do
        before do
          stock_transfer.update_attributes(closed_at: Time.now)
        end

        it { is_expected.to eq false }
      end

      context "finalized and closed" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.now, closed_at: Time.now)
        end

        it { is_expected.to eq false }
      end

      context "shipped and closed" do
        before do
          stock_transfer.update_attributes(shipped_at: Time.now, closed_at: Time.now)
        end

        it { is_expected.to eq false }
      end

      context "finalized and shipped" do
        before do
          stock_transfer.update_attributes(finalized_at: Time.now, shipped_at: Time.now)
        end

        it { is_expected.to eq true }
      end
    end
  end
end
