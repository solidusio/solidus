require 'spec_helper'

RSpec.describe Spree::Tax::TaxLocation do
  subject { described_class.new }

  it { is_expected.to respond_to(:state_id) }
  it { is_expected.to respond_to(:country_id) }

  describe "default values" do
    it "has a nil state and country id" do
      expect(subject.state_id).to eq(nil)
      expect(subject.country_id).to eq(nil)
    end
  end

  describe "initialization" do
    subject { described_class.new(args) }

    let(:country) { build_stubbed(:country) }
    let(:state) { build_stubbed(:state) }

    context "with a country id" do
      let(:args) { {country_id: country.id} }

      it "will yield a location with that country's id" do
        expect(subject.country_id).to eq(country.id)
      end
    end

    context 'with a country object' do
      let(:args) { {country: country} }

      it "will yield a location with that country's id" do
        expect(subject.country_id).to eq(country.id)
      end
    end

    context "with a state id" do
      let(:args) { {state_id: state.id} }

      it "will yield a location with that state's id" do
        expect(subject.state_id).to eq(state.id)
      end
    end

    context 'with a state object' do
      let(:args) { {state: state} }

      it "will yield a location with that state's id" do
        expect(subject.state_id).to eq(state.id)
      end
    end
  end
end
