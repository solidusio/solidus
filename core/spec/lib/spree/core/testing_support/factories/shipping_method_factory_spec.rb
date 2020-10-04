# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/shipping_method_factory'

RSpec.describe 'shipping method factory' do
  let(:factory_class) { Spree::ShippingMethod }

  describe 'plain shipping method' do
    let(:factory) { :shipping_method }

    it_behaves_like 'a working factory'

    it "should set calculable correctly" do
      shipping_method = create(factory)
      expect(shipping_method.calculator.calculable).to eq(shipping_method)
    end

    context 'store using alternate currency' do
      before { stub_spree_preferences(currency: 'CAD') }

      it "should configure the calculator correctly" do
        shipping_method = create(factory)
        expect(shipping_method.calculator.preferences[:currency]).to eq('CAD')
      end
    end
  end

  describe 'base shipping method' do
    let(:factory) { :base_shipping_method }

    it 'builds successfully' do
      expect(build(factory)).to be_a(factory_class)
    end

    # No test for create, as that is not intended somehow
  end

  describe 'free shipping method' do
    let(:factory) { :free_shipping_method }

    it_behaves_like 'a working factory'
  end
end
