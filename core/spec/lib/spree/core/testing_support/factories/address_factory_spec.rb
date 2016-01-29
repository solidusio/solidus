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

  describe 'when passing in a country iso code' do
    subject { build(:address, country_iso_code: "RO") }

    it 'creates a valid address with actually valid data' do
      expect(subject).to be_valid
    end
  end
end
