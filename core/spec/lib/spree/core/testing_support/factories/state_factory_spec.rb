require 'spec_helper'
require 'spree/testing_support/factories/state_factory'

RSpec.describe 'state factory' do
  let(:factory_class) { Spree::State }

  describe 'plain state' do
    let(:factory) { :state }

    it_behaves_like 'a working factory'

    it 'is Alabama' do
      expect(build(factory).abbr).to eq('AL')
      expect(build(factory).name).to eq('Alabama')
    end
  end

  describe 'when give a country iso code' do
    it 'creates the first state for that country it finds in carmen' do
      expect(build(:state, country_iso: "DE").abbr).to eq("BW")
      expect(build(:state, country_iso: "DE").name).to eq("Baden-Württemberg")
    end
  end
end
