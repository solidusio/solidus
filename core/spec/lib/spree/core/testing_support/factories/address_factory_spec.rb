# frozen_string_literal: true

require 'rails_helper'

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

  context 'states and countries' do
    describe 'country requiring a state' do
      let(:state) { create(:state, country_iso: 'IT', state_code: 'PE' )}
      let(:country) { create(:country, iso: 'IT' )}

      context 'when given a state but no country' do
        subject { build(:address, state: state) }

        it 'infers the country from the state' do
          expect(subject).to be_valid
          expect(subject.state.abbr).to eq("PE")
          expect(subject.country.iso).to eq("IT")
        end
      end

      context 'when given a country but no state' do
        subject { build(:address, country: country) }

        it 'automatically finds or creates an appropriate state' do
          expect(subject).to be_valid
          expect(subject.state.abbr).to eq("AL")
          expect(subject.country.iso).to eq("IT")
        end
      end

      context 'when given a country, no state but a state_name' do
        subject { build(:address, country: country, state_name: 'Bogus state') }

        it 'does not automatically find or create an appropriate state' do
          expect(subject).to be_valid
          expect(subject.state).to be_nil
          expect(subject.state_name).to eq('Bogus state')
        end
      end
    end

    describe 'country not requiring a state' do
      subject { build(:address, country: country) }
      let(:country) { create(:country, iso: 'AI' )}

      it 'does not automatically find or create an appropriate state' do
        expect(subject).to be_valid
        expect(subject.state).to be_nil
        expect(subject.country.iso).to eq("AI")
      end
    end

    describe 'when passing in a state and country ISO' do
      subject { build(:address, country_iso_code: country_iso_code, state_code: state_code) }

      context 'when the country has a state with proper code' do
        let(:country_iso_code) { "US" }
        let(:state_code) { "NY" }

        it 'works' do
          expect(subject).to be_valid
          expect(subject.state.abbr).to eq("NY")
          expect(subject.country.iso).to eq("US")
        end
      end
    end
  end

  describe 'creating multiple addresses' do
    let!(:address1) { create(:address) }
    let!(:address2) { create(:address) }

    it 'shares the same country and state objects' do
      expect(address1.country).to eq(address2.country)
      expect(address1.state).to eq(address2.state)
      expect(Spree::Country.count).to eq(1)
      expect(Spree::State.count).to eq(1)
    end
  end
end

