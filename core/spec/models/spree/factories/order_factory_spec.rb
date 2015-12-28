ENV['NO_FACTORIES'] = "NO FACTORIES"

require 'spec_helper'
require 'spree/testing_support/factories/order_factory'

RSpec.shared_examples_for 'an order factory' do
  it "builds" do
    expect(build factory).to be_a(factory_class)
  end

  it "creates" do
    expect(create factory).to be_a(factory_class)
  end
end

RSpec.describe 'order factory', type: :model do
  let(:factory_class) { Spree::Order }

  describe 'plain order' do
    let(:factory) { :order }

    it_behaves_like 'an order factory'
  end


  describe 'order with totals' do
    let(:factory) { :order_with_totals }

    it_behaves_like 'an order factory'
  end

  describe 'order with line items' do
    let(:factory) { :order_with_line_items }

    it_behaves_like 'an order factory'
  end

  describe 'completed order with totals' do
    let(:factory) { :completed_order_with_totals }

    it_behaves_like 'an order factory'
  end

  describe 'completed order with pending payment' do
    let(:factory) { :completed_order_with_pending_payment }

    it_behaves_like 'an order factory'
  end
end
