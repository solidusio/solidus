# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/working_factory'

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

  describe 'when given a country iso code' do
    let(:state) { build(:state, country_iso: "DE") }

    it 'creates the first state for that country it finds in carmen' do
      expect(state.abbr).to eq("BW")
      expect(state.name).to eq("Baden-Württemberg")
    end

    context 'of an existing country' do
      let!(:country){ create(:country, iso: "DE") }
      it 'uses the existing country in the database' do
        expect(state.country).to eq(country)
        expect(Spree::Country.count).to eq(1)
      end
    end
  end

  describe 'for a country with nested carmen states' do
    context 'when not given a state_iso' do
      let(:state) { build(:state, country_iso: "IT") }

      it 'creates the first state for that country it finds in carmen' do
        expect(state.abbr).to eq("AL")
        expect(state.name).to eq("Alessandria")
      end
    end

    context 'when given a state_iso' do
      let(:state) { build(:state, country_iso: "IT", state_code: 'PE' ) }

      it 'finds the corresponding state' do
        expect(state.abbr).to eq("PE")
        expect(state.name).to eq("Pescara")
      end
    end
  end

  describe 'when given a country record' do
    let(:country) { build(:country, iso: "DE") }
    let(:state) { build(:state, country: country) }
    it 'creates the first state for that country it finds in carmen' do
      expect(state.abbr).to eq("BW")
      expect(state.name).to eq("Baden-Württemberg")
    end
  end

  describe 'when given an invalid country iso code' do
    it 'raises a helpful message' do
      expect{ build(:state, country_iso: "ZZ") }.to raise_error(RuntimeError, 'Unknown country iso code: "ZZ"')
    end
  end

  context 'with a country that does not have subregions' do
    it 'raises an exception' do
      expect {
        create(:state, country_iso: 'HK')
      }.to raise_error('Country HK has no subregions')
    end
  end
end
