# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Country, type: :model do
  describe '.default' do
    subject(:default_country) { described_class.default }

    context 'with the configuration setting an existing ISO code' do
      before do
        create(:country, iso: "DE")
        stub_spree_preferences(default_country_iso: "DE")
      end

      it 'is a country with the configurations ISO code' do
        expect(default_country).to be_a(Spree::Country)
        expect(default_country.iso).to eq('DE')
      end
    end

    context 'with the configuration setting an non-existing ISO code' do
      before { stub_spree_preferences(default_country_iso: "ZZ") }

      it 'raises a Record not Found error' do
        expect { default_country }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.available' do
    let!(:united_states) { create(:country, iso: 'US') }
    let!(:canada) { create(:country, iso: 'CA') }
    let!(:italy) { create(:country, iso: 'IT') }
    let!(:custom_zone) { create(:zone, name: 'Custom Zone', countries: [united_states, italy]) }

    context 'with a checkout zone defined' do
      context 'when checkout zone is of type country' do
        let!(:checkout_zone) { create(:zone, name: 'Checkout Zone', countries: [united_states, canada]) }

        before do
          stub_spree_preferences(checkout_zone: checkout_zone.name)
        end

        context 'with no arguments' do
          it 'returns "Checkout Zone" countries' do
            expect(described_class.available).to be_an(ActiveRecord::Relation)
            expect(described_class.available).to contain_exactly(united_states, canada)
          end
        end

        context 'setting nil as restricting zone' do
          it 'returns all countries' do
            expect(described_class.available(restrict_to_zone: nil)).to be_an(ActiveRecord::Relation)
            expect(described_class.available(restrict_to_zone: nil)).to contain_exactly(united_states, canada, italy)
          end
        end

        context 'setting "Custom Zone" as restricting zone' do
          it 'returns "Custom Zone" countries' do
            expect(described_class.available(restrict_to_zone: 'Custom Zone')).to be_an(ActiveRecord::Relation)
            expect(described_class.available(restrict_to_zone: 'Custom Zone')).to contain_exactly(united_states, italy)
          end
        end

        context 'setting "Checkout Zone" as restricting zone' do
          it 'returns "Checkout Zone" countries' do
            expect(described_class.available(restrict_to_zone: 'Checkout Zone')).to be_an(ActiveRecord::Relation)
            expect(described_class.available(restrict_to_zone: 'Checkout Zone')).to contain_exactly(united_states, canada)
          end
        end
      end

      context 'when checkout zone is of type state' do
        let!(:state) { create(:state, country: united_states) }
        let!(:checkout_zone) { create(:zone, name: 'Checkout Zone', states: [state]) }

        before do
          stub_spree_preferences(checkout_zone: checkout_zone.name)
        end

        context 'with no arguments' do
          it 'returns all countries' do
            expect(described_class.available(restrict_to_zone: nil)).to contain_exactly(united_states, canada, italy)
          end
        end
      end
    end

    context 'with no checkout zone defined' do
      context 'with no arguments' do
        it 'returns all countries' do
          expect(described_class.available).to contain_exactly(united_states, canada, italy)
        end
      end

      context 'setting nil as restricting zone' do
        it 'returns all countries' do
          expect(described_class.available(restrict_to_zone: nil)).to contain_exactly(united_states, canada, italy)
        end
      end

      context 'setting "Custom Zone" as restricting zone' do
        it 'returns "Custom Zone" countries' do
          expect(described_class.available(restrict_to_zone: 'Custom Zone')).to contain_exactly(united_states, italy)
        end
      end
    end
  end

  describe '#prices' do
    let(:country) { create(:country, iso: "BR") }
    subject { country.prices }

    it { is_expected.to be_a(ActiveRecord::Associations::CollectionProxy) }

    context "if the country has associated prices" do
      let!(:price_one) { create(:price, country:) }
      let!(:price_two) { create(:price, country:) }
      let!(:price_three) { create(:price) }

      it { is_expected.to contain_exactly(price_one, price_two) }
    end
  end
end
