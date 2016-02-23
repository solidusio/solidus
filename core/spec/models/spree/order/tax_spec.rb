require 'spec_helper'

module Spree
  describe Spree::Order, type: :model do
    let(:order) { stub_model(Spree::Order) }

    context "#tax_zone" do
      let(:bill_address) { create :address }
      let(:ship_address) { create :address }
      let(:order) { Spree::Order.create(ship_address: ship_address, bill_address: bill_address) }
      let(:zone) { create :zone }

      context "when no zones exist" do
        it "should return nil" do
          expect(order.tax_zone).to be_nil
        end
      end

      context "when :tax_using_ship_address => true" do
        before { Spree::Config.set(tax_using_ship_address: true) }

        it "should calculate using ship_address" do
          expect(Spree::Zone).to receive(:match).at_least(:once).with(ship_address)
          expect(Spree::Zone).not_to receive(:match).with(bill_address)
          order.tax_zone
        end

        context 'when there is a default vat country and the order has no ship address' do
          let(:ship_address) { nil }

          before { Spree::Config.default_vat_country_iso = "US" }

          it 'will calculate using the default tax address' do
            expect(Spree::Zone).to receive(:match).at_least(:once)
                                                  .with(Spree::Config.default_tax_location)
            expect(Spree::Zone).not_to receive(:match).with(ship_address)
            order.tax_zone
          end
        end
      end

      context "when :tax_using_ship_address => false" do
        before { Spree::Config.set(tax_using_ship_address: false) }

        it "should calculate using bill_address" do
          expect(Spree::Zone).to receive(:match).at_least(:once).with(bill_address)
          expect(Spree::Zone).not_to receive(:match).with(ship_address)
          order.tax_zone
        end

        context 'when there is a default tax address and the order has bill address' do
          let(:bill_address) { nil }

          before { Spree::Config.default_vat_country_iso = "US" }

          it 'will calculate using the default tax address' do
            expect(Spree::Zone).to receive(:match).at_least(:once).with(Spree::Config.default_tax_location)
            expect(Spree::Zone).not_to receive(:match).with(bill_address)
            order.tax_zone
          end
        end
      end
    end
  end
end
