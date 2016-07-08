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

    it 'should contain out_of_stock_variants' do
      expect(Spree::Admin::ReportsController.available_reports.keys.include?(:out_of_stock_variants)).to be true
    end

    it 'should have the proper out_of_stock_variants report description' do
      expect(Spree::Admin::ReportsController.available_reports[:out_of_stock_variants][:description]).to eql('Variants that are out of stock')
    end
  end

  describe 'ReportsController.add_available_report!' do
    context 'when adding the report name' do
      it 'should contain the report' do
        I18n.backend.store_translations(:en, spree: {
          reports: {
            some_report: 'Awesome Report',
            some_report_description: 'This report is great!'
          }
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

  describe 'GET index' do
    it 'should be ok' do
      spree_get :index
      expect(response).to be_ok
    end
  end

  describe 'GET show' do
    it 'shows a report' do
      spree_get :show, id: :sales_total
      expect(response).to be_ok
    end
    it 'passes params to the report' do
      expect_any_instance_of(Spree::Report::SalesTotal).to receive(:initialize).with("foo" => "bar")
      spree_get :show, { id: :sales_total, foo: :bar }
    end
    it "returns an error if there's no such report" do
      spree_get :show, id: :some_report
      expect(response).to redirect_to spree.admin_reports_path
    end
  end

  after(:each) do
    Spree::Admin::ReportsController.available_reports.delete_if do |key, _value|
      key != :sales_total
    end
  end
end
