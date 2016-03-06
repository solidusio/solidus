require 'spec_helper'
require 'spree/testing_support/factories/order_factory'

RSpec.shared_examples_for 'a fresh order from the factory' do
  subject { FactoryGirl.send(strategy, factory, options) }

  let(:options) { {} }

  it 'can be saved' do
    expect { subject.save! }.not_to raise_error if strategy == :build
  end

  it 'only creates one order in the database' do
    expect { subject.save! }.to change(Spree::Order, :count).by(1)
  end

  it 'has a bill address' do
    expect(subject.bill_address).to be_a(Spree::Address)
  end

  it 'has a shipping address' do
    expect(subject.shipping_address).to be_a(Spree::Address)
  end

  it 'has a store' do
    expect(subject.store).to be_a(Spree::Store)
  end

  describe 'with options' do
    context 'setting the line item price' do
      let(:options) { {line_items_price: 15, line_items_count: 2} }

      it 'has two line items' do
        expect(subject.line_items.length).to eq(2)
      end

      it 'has a total of 30' do
        expect(subject.line_items.map(&:total).sum).to eq(30)
      end
    end
  end
end

RSpec.describe 'order factory' do
  let(:factory_class) { Spree::Order }

  describe 'plain order' do
    let(:factory) { :order }

    it_behaves_like 'a working factory'

    describe 'when built' do
      let(:strategy) { :build }

      it_behaves_like 'a fresh order from the factory'
    end

    describe 'when created' do
      let(:strategy) { :create }

      it_behaves_like 'a fresh order from the factory'
    end
  end

  describe 'order with totals' do
    let(:factory) { :order_with_totals }

    it_behaves_like 'a working factory'

    describe 'when built' do
      let(:strategy) { :build }

      it_behaves_like 'a fresh order from the factory'
    end

    describe 'when created' do
      let(:strategy) { :create }

      it_behaves_like 'a fresh order from the factory'
    end
  end

  describe 'order with line items' do
    let(:factory) { :order_with_line_items }

    it_behaves_like 'a working factory'

    describe 'when built' do
      let(:strategy) { :build }

      it_behaves_like 'a fresh order from the factory'

      it 'has one line item' do
        expect(build(factory).line_items.length).to eq(1)
      end
    end

    describe 'when created' do
      let(:strategy) { :create }

      it_behaves_like 'a fresh order from the factory'

      it 'has one line item' do
        expect(build(factory).line_items.length).to eq(1)
      end
    end
  end

  describe 'completed order with totals' do
    let(:factory) { :completed_order_with_totals }

    it_behaves_like 'a working factory'
  end

  describe 'completed order with pending payment' do
    let(:factory) { :completed_order_with_pending_payment }

    it_behaves_like 'a working factory'
  end

  describe 'order ready to ship' do
    let(:factory) { :order_ready_to_ship }

    it_behaves_like 'a working factory'
  end

  describe 'shipped order' do
    let(:factory) { :shipped_order }

    it_behaves_like 'a working factory'
  end
end
