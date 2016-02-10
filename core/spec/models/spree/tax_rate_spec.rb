require 'spec_helper'

describe Spree::TaxRate, type: :model do
  context '.for_address' do
    let(:germany) { create(:country, iso: "DE") }
    let(:germany_zone) { create(:zone, countries: [germany]) }
    let!(:german_tax) { create(:tax_rate, zone: germany_zone) }
    let(:france) { create(:country, iso: "FR") }
    let(:france_zone) { create(:zone, countries: [france]) }
    let!(:french_tax) { create(:tax_rate, zone: france_zone) }
    let(:eu_zone) { create(:zone, countries: [germany, france]) }
    let!(:eu_tax) { create(:tax_rate, zone: eu_zone) }
    let(:usa) { create(:country, iso: "US") }
    let(:us_zone) { create(:zone, countries: [usa]) }
    let!(:us_tax) { create(:tax_rate, zone: us_zone) }
    let(:new_york) { create(:state, country: usa, state_code: "NY") }
    let(:new_york_zone) { create(:zone, states: [new_york]) }
    let!(:new_york_tax) { create(:tax_rate, zone: new_york_zone) }
    let(:alabama) { create(:state, country: usa, state_code: "AL") }
    let(:alabama_zone) { create(:zone, states: [alabama]) }
    let!(:alabama_tax) { create(:tax_rate, zone: alabama_zone) }

    subject(:rates_for_address) { Spree::TaxRate.for_address(address) }

    context 'when address is in germany' do
      let(:address) { create(:address, country_iso_code: "DE") }

      it 'returns the eu and the german rate' do
        expect(rates_for_address).to include(german_tax)
        expect(rates_for_address).to include(eu_tax)
        expect(rates_for_address.length).to eq(2)
      end
    end

    context 'when address is in france' do
      let(:address) { create(:address, country_iso_code: "FR") }

      it 'returns the eu and the french rate' do
        expect(rates_for_address).to include(french_tax)
        expect(rates_for_address).to include(eu_tax)
        expect(rates_for_address.length).to eq(2)
      end
    end

    context 'when address is in new york' do
      let(:address) { create(:address, country_iso_code: "US", state_code: "NY") }

      it 'returns the new york rate and the federal rate' do
        expect(rates_for_address).to include(new_york_tax)
        expect(rates_for_address).to include(us_tax)
        expect(rates_for_address.length).to eq(2)
      end
    end

    context 'when address is in alabama' do
      let(:address) { create(:address, country_iso_code: "US", state_code: "AL") }

      it 'returns the new york rate and the federal rate' do
        expect(rates_for_address).to include(alabama_tax)
        expect(rates_for_address).to include(us_tax)
        expect(rates_for_address.length).to eq(2)
      end
    end

    context 'when address is in alaska' do
      let(:address) { create(:address, country_iso_code: "US", state_code: "AK") }

      it 'returns the new york rate and the federal rate' do
        expect(rates_for_address).to include(us_tax)
        expect(rates_for_address.length).to eq(1)
      end
    end
  end


  context ".for_zone" do
    subject(:rates_for_zone) { Spree::TaxRate.for_zone(zone) }

    context "when zone is nil" do
      let(:zone) { nil }

      it "should return an empty array" do
        expect(subject).to eq([])
      end
    end

    context "when no rate zones match the tax zone" do
      let(:rate_zone) { create(:zone, :with_country) }
      let!(:rate) { create :tax_rate, zone: rate_zone }

      context "when there is no default tax zone" do
        context "and the zone has no shared members with the rate zone" do
          let(:zone) { create(:zone, :with_country) }

          it "should return an empty array" do
            expect(subject).to eq([])
          end
        end

        context "and the zone has shared members with the rate zone" do
          let(:zone) { create(:zone, countries: rate_zone.countries) }

          it "should return the rate that matches the rate zone" do
            expect(subject).to eq([rate])
          end
        end

        context "there is many rates that match the zone" do
          let!(:rate2) { create :tax_rate, zone: rate_zone }
          let(:zone) { create(:zone, countries: rate_zone.countries) }

          it "should return all rates that match the rate zone" do
            expect(subject).to match_array([rate, rate2])
          end
        end

        context "when the tax_zone is contained within a rate zone" do
          let(:country1) { create :country }
          let(:country2) { create :country }
          let(:rate_zone) { create(:zone, countries: [country1, country2]) }
          let(:zone) { create(:zone, countries: [country1]) }

          it "should return the rate zone" do
            expect(subject).to eq([rate])
          end
        end
      end

      context "when there is a default tax zone" do
        let(:default_zone) { create(:zone, :with_country, default_tax: true) }
        let(:included_in_price) { false }
        let!(:rate) do
          create(:tax_rate, zone: default_zone, included_in_price: included_in_price)
        end

        context "when the zone is the default zone" do
          let(:zone) { default_zone }

          context "when the tax is not a VAT" do
            it { is_expected.to eq([rate]) }
          end

          context "when the tax is a VAT" do
            let(:included_in_price) { true }

            it { is_expected.to eq([rate]) }
          end
        end

        context "when the zone is outside the default zone" do
          let(:zone) { create(:zone, :with_country) }

          it { is_expected.to be_empty }
        end
      end
    end
  end

  context ".adjust" do
  #  let(:zone) { stub_model(Spree::Zone) }
  #  let(:address) { build_stubbed(:address) }
  #  let(:order) { build_stubbed(:order, ship_address: address) }

    context "with line items" do
      let(:line_item) { build_stubbed(:line_item) }

      it 'should emit a deprecation warning and call the item adjuster' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        expect(Spree::Tax::ItemAdjuster).to receive_message_chain(:new, :adjust!)
        Spree::TaxRate.adjust(nil, [line_item])
      end
    end

    context "with shipments" do
      let(:shipment) { build_stubbed(:shipment) }

      it 'should emit a deprecation warning and call the item adjuster' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        expect(Spree::Tax::ItemAdjuster).to receive_message_chain(:new, :adjust!)
        Spree::TaxRate.adjust(nil, [shipment])
      end
    end
  end
end
