ENV['NO_FACTORIES'] = "NO FACTORIES"

require 'spec_helper'
require 'spree/testing_support/factories/address_factory'

RSpec.describe 'address factory' do
  let(:factory_class) { Spree::Address }

  describe 'plain address' do
    let(:factory) { :address }

    it_behaves_like 'a working factory'
  end

  describe 'ship_address' do
    let(:factory) { :ship_address }

    it_behaves_like 'a working factory'
  end

  describe 'bill address' do
    let(:factory) { :bill_address }

    it_behaves_like 'a working factory'
  end
end
