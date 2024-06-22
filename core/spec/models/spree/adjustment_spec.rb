# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Adjustment, type: :model do
  let!(:store) { create :store }
  let(:order) { create :order }
  let(:line_item) { create :line_item, order: order }

  let(:adjustment) { Spree::Adjustment.create!(label: 'Adjustment', adjustable: order, order: order, amount: 5) }

  context '#save' do
    let(:adjustment) { Spree::Adjustment.create(label: "Adjustment", amount: 5, order: order, adjustable: line_item) }

    it 'touches the adjustable' do
      line_item.update_columns(updated_at: 1.day.ago)
      expect { adjustment.save! }.to change { line_item.updated_at }
    end
  end

  describe ".eligible", :silence_deprecations do
    subject { described_class.eligible.to_sql }

    it { is_expected.to eq(Spree::Adjustment.all.to_sql) }
  end

  describe 'non_tax scope' do
    subject do
      Spree::Adjustment.non_tax.to_a
    end

    let!(:tax_adjustment) do
      create(:adjustment, adjustable: order, order: order, source: create(:tax_rate))
    end

    let!(:non_tax_adjustment_with_source) do
      create(:adjustment, adjustable: order, order: order, source_type: 'Spree::Order', source_id: nil)
    end

    let!(:non_tax_adjustment_without_source) do
      create(:adjustment, adjustable: order, order: order, source: nil)
    end

    it 'select non-tax adjustments' do
      expect(subject).to_not include tax_adjustment
      expect(subject).to     include non_tax_adjustment_with_source
      expect(subject).to     include non_tax_adjustment_without_source
    end
  end

  context '#currency' do
    let(:order) { create :order, currency: 'JPY' }

    it 'returns the adjustables currency' do
      expect(adjustment.currency).to eq 'JPY'
    end

    context 'adjustable is nil' do
      before do
        adjustment.adjustable = nil
      end
      it 'uses the global currency of USD' do
        expect(adjustment.currency).to eq 'USD'
      end
    end
  end

  context "#display_amount" do
    before { adjustment.amount = 10.55 }

    it "shows the amount" do
      expect(adjustment.display_amount.to_s).to eq "$10.55"
    end

    context "with currency set to JPY" do
      let(:order) { create :order, currency: 'JPY' }

      context "when adjustable is set to an order" do
        it "displays in JPY" do
          expect(adjustment.display_amount.to_s).to eq "¥11"
        end
      end
    end
  end

  describe "#finalize" do
    let(:adjustable) { create(:order) }
    let(:adjustment) { build(:adjustment, finalized: false, adjustable: adjustable) }

    subject { adjustment.finalize }

    it "sets the adjustment as finalized" do
      expect { subject }.to change { adjustment.finalized }.from(false).to(true)
    end

    it "persists the adjustment" do
      expect { subject }.to change { adjustment.persisted? }.from(false).to(true)
    end

    context "for an invalid adjustment" do
      let(:adjustment) { build(:adjustment, finalized: false, amount: nil, adjustable: adjustable) }

      it "raises no error, returns false, does not persist the adjustment" do
        expect { subject }.not_to change { adjustment.persisted? }.from(false)
        expect(subject).to eq false
      end
    end
  end

  describe "#unfinalize" do
    let(:adjustable) { create(:order) }
    let(:adjustment) { build(:adjustment, finalized: true, adjustable: adjustable) }

    subject { adjustment.unfinalize }

    it "sets the adjustment as finalized" do
      expect { subject }.to change { adjustment.finalized }.from(true).to(false)
    end

    it "persists the adjustment" do
      expect { subject }.to change { adjustment.persisted? }.from(false).to(true)
    end

    context "for an invalid adjustment" do
      let(:adjustment) { build(:adjustment, finalized: false, amount: nil, adjustable: adjustable) }

      it "raises no error, returns false, does not persist the adjustment" do
        expect { subject }.not_to change { adjustment.persisted? }.from(false)
        expect(subject).to eq false
      end
    end
  end

  describe "#unfinalize!" do
    let(:adjustable) { create(:order) }
    let(:adjustment) { build(:adjustment, finalized: true, adjustable: adjustable) }

    subject { adjustment.unfinalize! }

    it "sets the adjustment as finalized" do
      expect { subject }.to change { adjustment.finalized }.from(true).to(false)
    end

    it "persists the adjustment" do
      expect { subject }.to change { adjustment.persisted? }.from(false).to(true)
    end

    context "for an invalid adjustment" do
      let(:adjustment) { build(:adjustment, finalized: false, amount: nil, adjustable: adjustable) }

      it "raises an error" do
        expect { subject }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#cancellation?" do
    subject { adjustment.cancellation? }

    context "when the adjustment is a cancellation" do
      let(:adjustment) { build(:adjustment, source_type: "Spree::UnitCancel") }

      it { is_expected.to eq true }
    end

    context "when the adjustment is not a cancellation" do
      let(:adjustment) { build(:adjustment) }

      it { is_expected.to eq false }
    end
  end
end
