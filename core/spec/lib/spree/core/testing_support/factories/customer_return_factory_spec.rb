# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/customer_return_factory'

RSpec.describe 'customer return factory' do
  let(:factory_class) { Spree::CustomerReturn }

  describe 'customer return' do
    let(:factory) { :customer_return }

    it_behaves_like 'a working factory'

    # Regression test for https://github.com/solidusio/solidus/pull/697
    it "creates only one of dependent records" do
      create(:customer_return, line_items_count: 2)
      aggregate_failures "items created" do
        expect(Spree::Order.count).to eq(1)
        expect(Spree::ReturnAuthorization.count).to eq(1)
      end
    end
  end

  describe 'customer return with accepted items' do
    let(:factory) { :customer_return_with_accepted_items }

    it_behaves_like 'a working factory'
  end

  describe 'customer return without return items' do
    let(:factory) { :customer_return_without_return_items }

    it "builds successfully" do
      expect(build(factory)).to be_a(factory_class)
    end

    # No create test, because this factory is (intentionally) invalid
  end
end
