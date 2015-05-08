require 'spec_helper'

module Spree
  describe StockTransfer, :type => :model do
    let(:destination_location) { create(:stock_location_with_items) }
    let(:source_location) { create(:stock_location_with_items) }
    let(:stock_item) { source_location.stock_items.order(:id).first }
    let(:variant) { stock_item.variant }
    let(:stock_transfer) { StockTransfer.create(description: 'PO123') }

    subject { stock_transfer }

    its(:description) { should eq 'PO123' }
    its(:to_param) { should match /T\d+/ }

    describe "#receivable?" do
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

    describe "#finalizable?" do
      subject { stock_transfer.finalizable? }

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

      it "sets a finalized_at date" do
        expect { subject }.to change { stock_transfer.finalized_at }
      end

      it "sets the finalized_by to the supplied user" do
        subject
        expect(stock_transfer.finalized_by).to eq user
      end
    end

    describe "#close" do
      let(:user) { create(:user) }

      subject { stock_transfer.close(user) }

      it "sets a closed_at date" do
        expect { subject }.to change { stock_transfer.closed_at }
      end

      it "sets the closed_by to the supplied user" do
        subject
        expect(stock_transfer.closed_by).to eq user
      end
    end
  end
end
