require 'spec_helper'

describe Spree::Country, type: :model do
  describe '.default' do
    before do
      create(:country, iso: "DE", id: 1)
      create(:country, id: 2)
    end

    context 'with the configuration setting an existing ISO code' do
      it 'is a country with the configurations ISO code' do
        expect(described_class.default).to be_a(Spree::Country)
        expect(described_class.default.iso).to eq('US')
      end
    end

    context 'with the configuration setting an non-existing ISO code' do
      before { Spree::Config[:default_country_iso] = "ZZ" }

      it 'raises a Record not Found error' do
        expect { described_class.default }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
