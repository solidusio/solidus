require 'spec_helper'

describe Spree::Admin::ReportsController, type: :controller do
  stub_authorization!

  describe 'ReportsController.available_reports' do
    it 'should contain sales_total' do
      expect(Spree::Admin::ReportsController.available_reports.keys.include?(:sales_total)).to be true
    end

    it 'should have the proper sales total report description' do
      expect(Spree::Admin::ReportsController.available_reports[:sales_total][:description]).to eql('Sales Total For All Orders')
    end
  end

  describe 'ReportsController.add_available_report!' do
    context 'when adding the report name' do
      it 'should contain the report' do
        I18n.backend.store_translations(:en, spree: {
          some_report: 'Awesome Report',
          some_report_description: 'This report is great!'
        })
        Spree::Admin::ReportsController.add_available_report!(:some_report)
        expect(Spree::Admin::ReportsController.available_reports.keys.include?(:some_report)).to be true
        expect(Spree::Admin::ReportsController.available_reports[:some_report]).to eq(
          name: 'Awesome Report',
          description: 'This report is great!'
        )
      end
    end
  end

  describe 'GET sales_total' do
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

    subject { get :sales_total, params }

    shared_examples 'sales total report' do
      it 'should respond with success' do
        expect(response).to be_success
      end

      it 'should set search to be a ransack search' do
        subject
        expect(assigns(:search)).to be_a Ransack::Search
      end

      it 'should set orders correctly for date parameters' do
        subject
        expect(assigns(:orders)).to eq expected_returned_orders
      end

      it 'does not include non-complete orders' do
        subject
        expect(assigns(:orders)).to_not include(order_non_complete)
      end

      it 'should correctly set the totals hash' do
        subject
        expect(assigns(:totals)).to eq expected_totals
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
      let(:params) { { q: { completed_at_gt: Time.current.beginning_of_month + 1.day } } }

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
      let(:params) { { q: { completed_at_lt: Time.current.beginning_of_month } } }

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

  describe 'GET index' do
    it 'should be ok' do
      get :index
      expect(response).to be_ok
    end
  end

  after(:each) do
    Spree::Admin::ReportsController.available_reports.delete_if do |key, _value|
      key != :sales_total
    end
  end
end
