ENV['NO_FACTORIES'] = "NO FACTORIES"

require 'spec_helper'
require 'spree/testing_support/factories/shipping_method_factory'

RSpec.describe 'shipping method factory' do
  let(:factory_class) { Spree::ShippingMethod }

  describe 'plain shipping method' do
    let(:factory) { :shipping_method }

    it_behaves_like 'a working factory'
  end

  describe 'base shipping method' do
    let(:factory) { :base_shipping_method }

    it 'builds successfully' do
      expect(build factory).to be_a(factory_class)
    end

    # No test for create, as that is not intended somehow
  end

  describe 'free shipping method' do
    let(:factory) { :free_shipping_method }

    it_behaves_like 'a working factory'
  end
end
