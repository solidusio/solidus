require 'spec_helper'

describe Spree::Report::SalesTotal, type: :model do
  let!(:order_complete_start_of_month) { create(:completed_order_with_totals) }
  let!(:order_complete_mid_month) { create(:completed_order_with_totals) }
  let!(:order_non_complete) { create(:order, completed_at: nil) }

  before do
    # can't set completed_at during factory creation
    order_complete_start_of_month.completed_at = Time.current.beginning_of_month + 1.minute
    order_complete_start_of_month.save!

    order_complete_mid_month.completed_at = Time.current.beginning_of_month + 15.days
    order_complete_mid_month.save!
  end

  describe '#content' do
    subject { Spree::Report::SalesTotal.new(params).content }

    shared_examples 'sales total report' do
      it 'should set search to be a ransack search' do
        subject
        expect(subject[:search]).to be_a Ransack::Search
      end

      it 'should set orders correctly for date parameters' do
        subject
        expect(subject[:orders]).to eq expected_returned_orders
      end

      it 'does not include non-complete orders' do
        subject
        expect(subject[:orders]).to_not include(order_non_complete)
      end

      it 'should correctly set the totals hash' do
        subject
        expect(subject[:totals]).to eq expected_totals
      end
    end

    context 'when no dates are specified' do
      let(:params) { {} }

      it_behaves_like 'sales total report' do
        let(:expected_returned_orders) { [order_complete_mid_month, order_complete_start_of_month] }
        let(:expected_totals) {
          {
            'USD' => {
              item_total: Money.new(2000, 'USD'),
              adjustment_total: Money.new(0, 'USD'),
              sales_total: Money.new(22_000, 'USD')
            }
          }
        }
      end
    end

    context 'when params has a completed_at_gt' do
      let(:params) { { q: { completed_at_gt: (Time.current.beginning_of_month + 1.day).strftime('%Y/%m/%d') } } }

      it_behaves_like 'sales total report' do
        let(:expected_returned_orders) { [order_complete_mid_month] }
        let(:expected_totals) {
          {
            'USD' => {
              item_total: Money.new(1000, 'USD'),
              adjustment_total: Money.new(0, 'USD'),
              sales_total: Money.new(11_000, 'USD')
            }
          }
        }
      end
    end

    context 'when params has a compeleted_at_lt' do
      let(:params) { { q: { completed_at_lt: Time.current.beginning_of_month.strftime('%Y/%m/%d') } } }

      it_behaves_like 'sales total report' do
        let(:expected_returned_orders) { [order_complete_start_of_month] }
        let(:expected_totals) {
          {
            'USD' => {
              item_total: Money.new(1000, 'USD'),
              adjustment_total: Money.new(0, 'USD'),
              sales_total: Money.new(11_000, 'USD')
            }
          }
        }
      end
    end
  end
end
