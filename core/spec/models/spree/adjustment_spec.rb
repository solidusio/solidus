# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Adjustment, type: :model do
  let!(:store) { create :store }
  let(:order) { Spree::Order.new }
  let(:line_item) { create :line_item, order: order }

  let(:adjustment) { Spree::Adjustment.create!(label: 'Adjustment', adjustable: order, order: order, amount: 5) }

  context '#save' do
    let(:adjustment) { Spree::Adjustment.create(label: "Adjustment", amount: 5, order: order, adjustable: line_item) }

    it 'touches the adjustable' do
      line_item.update_columns(updated_at: 1.day.ago)
      expect { adjustment.save! }.to change { line_item.updated_at }
    end
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
    let(:order) { Spree::Order.new currency: 'JPY' }

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
      let(:order) { Spree::Order.new currency: 'JPY' }

      context "when adjustable is set to an order" do
        it "displays in JPY" do
          expect(adjustment.display_amount.to_s).to eq "¥11"
        end
      end
    end
  end

  context '#recalculate' do
    subject { adjustment.recalculate }
    let(:adjustment) do
      line_item.adjustments.create!(
        label: 'Adjustment',
        order: order,
        adjustable: order,
        amount: 5,
        finalized: finalized,
        source: source,
      )
    end
    let(:order) { create(:order_with_line_items, line_items_price: 100) }
    let(:line_item) { order.line_items.to_a.first }

    context "when adjustment is finalized" do
      let(:finalized) { true }

      context 'with a promotion adjustment' do
        let(:source) { promotion.actions.first! }
        let(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: 7) }

        it 'does not update the adjustment' do
          expect { subject }.not_to change { adjustment.amount }
        end
      end

      context 'with a tax adjustment' do
        let(:source) { mock_model(Spree::TaxRate, compute_amount: 10) }

        it 'updates the adjustment' do
          expect { subject }.to change { adjustment.amount }.from(5).to(10)
        end
      end

      context 'with a sourceless adjustment' do
        let(:source) { nil }

        it 'does nothing' do
          expect { subject }.not_to change { adjustment.amount }
        end
      end
    end

    context "when adjustment isn't finalized" do
      let(:finalized) { false }

      context 'with a promotion adjustment' do
        let(:source) { promotion.actions.first! }
        let(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: 7) }

        context 'when the promotion is eligible' do
          it 'updates the adjustment' do
            expect { subject }.to change { adjustment.amount }.from(5).to(-7)
          end

          it 'sets the adjustment elgiible to true' do
            subject
            expect(adjustment.eligible).to eq(true)
          end
        end

        context 'when the promotion is not eligible' do
          before do
            promotion.update!(starts_at: 1.day.from_now)
          end

          it 'zeros out the adjustment' do
            expect { subject }.to change { adjustment.amount }.from(5).to(0)
          end

          it 'sets the adjustment elgiible to false' do
            subject
            expect(adjustment.eligible).to eq(false)
          end
        end
      end

      context 'with a tax adjustment' do
        let(:source) { mock_model(Spree::TaxRate, compute_amount: 10) }

        it 'updates the adjustment' do
          expect { subject }.to change { adjustment.amount }.from(5).to(10)
        end
      end

      context 'with a sourceless adjustment' do
        let(:source) { nil }

        it 'does nothing' do
          expect { subject }.to_not change { adjustment.amount }
        end
      end
    end
  end

  describe "promotion code presence error" do
    subject do
      adjustment.valid?
      adjustment.errors[:promotion_code]
    end

    context "when the adjustment is not a promotion adjustment" do
      let(:adjustment) { build(:adjustment) }

      it { is_expected.to be_blank }
    end

    context "when the adjustment is a promotion adjustment" do
      let(:adjustment) { build(:adjustment, source: promotion.actions.first) }
      let(:promotion) { create(:promotion, :with_order_adjustment) }

      context "when the promotion does not have a code" do
        it { is_expected.to be_blank }
      end

      context "when the promotion has a code" do
        let!(:promotion_code) { create(:promotion_code, promotion: promotion) }

        it { is_expected.to include("can't be blank") }
      end
    end
  end

  describe 'repairing adjustment associations' do
    context 'on create' do
      let(:adjustable) { order }
      let(:adjustment_source) { promotion.actions[0] }
      let(:order) { create(:order) }
      let(:promotion) { create(:promotion, :with_line_item_adjustment) }

      def expect_deprecation_warning
        expect(Spree::Deprecation).to(
          receive(:warn).
          with(
            /Adjustment \d+ was not added to #{adjustable.class} #{adjustable.id}/,
            instance_of(Array),
          )
        )
      end

      context 'when adding adjustments via the wrong association' do
        def create_adjustment
          adjustment_source.adjustments.create!(
            amount: 10,
            adjustable: adjustable,
            order: order,
            label: 'some label',
          )
        end

        context 'when adjustable.adjustments is loaded' do
          before { adjustable.adjustments.to_a }

          it 'repairs adjustable.adjustments' do
            expect_deprecation_warning
            adjustment = create_adjustment
            expect(adjustable.adjustments).to include(adjustment)
          end

          context 'when the adjustment is destroyed before after_commit runs' do
            it 'does not repair' do
              expect(Spree::Deprecation).not_to receive(:warn)
              Spree::Adjustment.transaction do
                adjustment = create_adjustment
                adjustment.destroy!
              end
            end
          end
        end

        context 'when adjustable.adjustments is not loaded' do
          it 'does repair' do
            expect(Spree::Deprecation).not_to receive(:warn)
            create_adjustment
          end
        end
      end

      context 'when adding adjustments via the correct association' do
        def create_adjustment
          adjustable.adjustments.create!(
            amount: 10,
            source: adjustment_source,
            order: order,
            label: 'some label',
          )
        end

        context 'when adjustable.adjustments is loaded' do
          before { adjustable.adjustments.to_a }

          it 'does not repair' do
            expect(Spree::Deprecation).not_to receive(:warn)
            create_adjustment
          end
        end

        context 'when adjustable.adjustments is not loaded' do
          it 'does not repair' do
            expect(Spree::Deprecation).not_to receive(:warn)
            create_adjustment
          end
        end
      end
    end

    context 'on destroy' do
      let(:adjustment) { create(:adjustment) }
      let(:adjustable) { adjustment.adjustable }

      def expect_deprecation_warning(adjustable)
        expect(Spree::Deprecation).to(
          receive(:warn).
          with(
            /Adjustment #{adjustment.id} was not removed from #{adjustable.class} #{adjustable.id}/,
            instance_of(Array),
          )
        )
      end

      context 'when destroying adjustments not via association' do
        context 'when adjustable.adjustments is loaded' do
          before { adjustable.adjustments.to_a }

          it 'repairs adjustable.adjustments' do
            expect_deprecation_warning(adjustable)
            adjustment.destroy!
            expect(adjustable.adjustments).not_to include(adjustment)
          end
        end

        context 'when adjustable.adjustments is not loaded' do
          it 'does not repair' do
            expect(Spree::Deprecation).not_to receive(:warn)
            adjustment.destroy!
          end
        end
      end

      context 'when destroying adjustments via the association' do
        context 'when adjustable.adjustments is loaded' do
          before { adjustable.adjustments.to_a }

          it 'does not repair' do
            expect(Spree::Deprecation).not_to receive(:warn)
            adjustable.adjustments.destroy(adjustment)
          end
        end

        context 'when adjustable.adjustments is not loaded' do
          it 'does not repair' do
            expect(Spree::Deprecation).not_to receive(:warn)
            adjustable.adjustments.destroy(adjustment)
          end
        end
      end
    end
  end
end
