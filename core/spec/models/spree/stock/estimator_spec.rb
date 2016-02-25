require 'spec_helper'

module Spree
  module Stock
    describe Estimator, type: :model do
      let(:shipping_rate) { 4.00 }
      let!(:shipping_method) { create(:shipping_method, cost: shipping_rate, currency: currency) }
      let(:package) do
        build(:stock_package, contents: inventory_units.map { |i| ContentItem.new(i) }).tap do |p|
          p.shipment = p.to_shipment
        end
      end
      let(:order) { create(:order_with_line_items, shipping_method: shipping_method) }
      let(:inventory_units) { order.inventory_units }

      subject { Estimator.new }

      context "#shipping rates" do
        before(:each) do
          shipping_method.zones.first.members.create(zoneable: order.ship_address.country)
        end

        let(:currency) { "USD" }

        context 'without a shipment' do
          before { package.shipment = nil }
          it 'raises an error' do
            expect {
              subject.shipping_rates(package)
            }.to raise_error(Spree::Stock::Estimator::ShipmentRequired)
          end
        end

        context 'without an order' do
          before { package.shipment.order = nil }
          it 'raises an error' do
            expect {
              subject.shipping_rates(package)
            }.to raise_error(Spree::Stock::Estimator::OrderRequired)
          end
        end

        shared_examples_for "shipping rate matches" do
          it "returns shipping rates" do
            shipping_rates = subject.shipping_rates(package)
            expect(shipping_rates.first.cost).to eq 4.00
          end
        end

        shared_examples_for "shipping rate doesn't match" do
          it "does not return shipping rates" do
            shipping_rates = subject.shipping_rates(package)
            expect(shipping_rates).to eq([])
          end
        end

        context "when the order's ship address is in the same zone" do
          it_should_behave_like "shipping rate matches"
        end

        context "when the order's ship address is in a different zone" do
          before { shipping_method.zones.each{ |z| z.members.delete_all } }
          it_should_behave_like "shipping rate doesn't match"
        end

        context "when the currency is nil" do
          let(:currency) { nil }
          it_should_behave_like "shipping rate matches"
        end

        context "when the currency is an empty string" do
          let(:currency) { "" }
          it_should_behave_like "shipping rate matches"
        end

        context "when the current matches the order's currency" do
          it_should_behave_like "shipping rate matches"
        end

        context "if the currency is different than the order's currency" do
          let(:currency) { "GBP" }
          it_should_behave_like "shipping rate doesn't match"
        end

        it "sorts shipping rates by cost" do
          ShippingMethod.destroy_all
          create(:shipping_method, cost: 5)
          create(:shipping_method, cost: 3)
          create(:shipping_method, cost: 4)

          expect(subject.shipping_rates(package).map(&:cost)).to eq [3.00, 4.00, 5.00]
        end

        context "general shipping methods" do
          before { Spree::ShippingMethod.destroy_all }

          context 'with two shipping methods of different cost' do
            let!(:shipping_methods) do
              [
                create(:shipping_method, cost: 5),
                create(:shipping_method, cost: 3)
              ]
            end

            it "selects the most affordable shipping rate" do
              expect(subject.shipping_rates(package).sort_by(&:cost).map(&:selected)).to eq [true, false]
            end
          end

          context 'with one of the shipping methods having nil cost' do
            let!(:shipping_methods) do
              [
                create(:shipping_method, cost: 1),
                create(:shipping_method, cost: nil)
              ]
            end

            it "selects the most affordable shipping rate and doesn't raise exception over nil cost" do
              allow(shipping_methods[1]).to receive_message_chain(:calculator, :compute).and_return(nil)
              allow(subject).to receive(:shipping_methods).and_return(shipping_methods)

              expect(subject.shipping_rates(package).map(&:shipping_method)).to eq([shipping_methods[0]])
            end
          end
        end

        context "involves backend only shipping methods" do
          before{ Spree::ShippingMethod.destroy_all }
          let!(:backend_method) { create(:shipping_method, display_on: "back_end", cost: 0.00) }
          let!(:generic_method) { create(:shipping_method, cost: 5.00) }

          it "does not return backend rates at all" do
            expect(subject.shipping_rates(package).map(&:shipping_method_id)).to eq([generic_method.id])
          end

          # regression for https://github.com/spree/spree/issues/3287
          it "doesn't select backend rates even if they're more affordable" do
            expect(subject.shipping_rates(package).map(&:selected)).to eq [true]
          end
        end

        context "includes tax adjustments if applicable" do
          let!(:tax_rate) { create(:tax_rate, zone: order.tax_zone) }

          before do
            shipping_method.update!(tax_category: tax_rate.tax_category)
          end

          it "links the shipping rate and the tax rate" do
            shipping_rates = subject.shipping_rates(package)
            expect(shipping_rates.first.taxes.first.tax_rate).to eq(tax_rate)
          end
        end

        it 'uses the configured shipping rate selector' do
          shipping_rate = build(:shipping_rate)
          allow(Spree::ShippingRate).to receive(:new).and_return(shipping_rate)

          selector_class = Class.new do
            def initialize(_); end;

            def find_default
              Spree::ShippingRate.new
            end
          end
          Spree::Config.shipping_rate_selector_class = selector_class

          subject.shipping_rates(package)

          expect(shipping_rate.selected).to eq(true)

          Spree::Config.shipping_rate_selector_class = nil
        end

        it 'uses the configured shipping rate sorter' do
          class Spree::Stock::TestSorter; end;
          Spree::Config.shipping_rate_sorter_class = Spree::Stock::TestSorter

          sorter = double(:sorter, sort: nil)
          allow(Spree::Stock::TestSorter).to receive(:new).and_return(sorter)

          subject.shipping_rates(package)

          expect(sorter).to have_received(:sort)

          Spree::Config.shipping_rate_sorter_class = nil
        end

        it 'uses the configured shipping rate taxer' do
          class Spree::Tax::TestTaxer
            def initialize
            end

            def tax(_)
              Spree::ShippingRate.new
            end
          end
          Spree::Config.shipping_rate_taxer_class = Spree::Tax::TestTaxer

          shipping_rate = Spree::ShippingRate.new
          allow(Spree::ShippingRate).to receive(:new).and_return(shipping_rate)

          expect(Spree::Tax::TestTaxer).to receive(:new).and_call_original
          subject.shipping_rates(package)
        end
      end
    end
  end
end
