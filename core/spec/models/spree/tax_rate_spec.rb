require 'spec_helper'

describe Spree::TaxRate, type: :model do
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
    let(:zone) { stub_model(Spree::Zone) }

    context "with line items" do
      let(:line_item) { stub_model(Spree::LineItem) }

      it 'should emit a deprecation warning and call the item adjuster' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        expect(Spree::Tax::ItemAdjuster).to receive_message_chain(:new, :adjust!)
        Spree::TaxRate.adjust(zone, [line_item])
      end
    end

    context "with shipments" do
      let(:shipment) { stub_model(Spree::Shipment) }

      it 'should emit a deprecation warning and call the item adjuster' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
        expect(Spree::Tax::ItemAdjuster).to receive_message_chain(:new, :adjust!)
        Spree::TaxRate.adjust(zone, [shipment])
      end
    end
  end
end
