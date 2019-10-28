# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe Estimator, type: :model do
      let(:shipping_rate) { 4.00 }
      let!(:shipping_method) { create(:shipping_method, cost: shipping_rate, currency: currency) }
      let(:package) do
        build(:stock_package, contents: inventory_units.map { |unit| ContentItem.new(unit) }).tap do |package|
          package.shipment = package.to_shipment
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
          before { shipping_method.zones.each{ |zone| zone.members.delete_all } }
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
          ShippingMethod.all.each(&:really_destroy!)
          create(:shipping_method, cost: 5)
          create(:shipping_method, cost: 3)
          create(:shipping_method, cost: 4)

          expect(subject.shipping_rates(package).map(&:cost)).to eq [3.00, 4.00, 5.00]
        end

        context "general shipping methods" do
          before { Spree::ShippingMethod.all.each(&:really_destroy!) }

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
          before{ Spree::ShippingMethod.all.each(&:really_destroy!) }
          let!(:backend_method) { create(:shipping_method, available_to_users: false, cost: 0.00) }
          let!(:generic_method) { create(:shipping_method, cost: 5.00) }

          it "does not return backend rates at all" do
            expect(subject.shipping_rates(package).map(&:shipping_method_id)).to eq([generic_method.id])
          end

          # regression for https://github.com/spree/spree/issues/3287
          it "doesn't select backend rates even if they're more affordable" do
            expect(subject.shipping_rates(package).map(&:selected)).to eq [true]
          end
        end

        context "excludes shipping methods from other stores" do
          before{ Spree::ShippingMethod.all.each(&:really_destroy!) }

          let!(:other_method) do
            create(
              :shipping_method,
              cost: 0.00,
              stores: [build(:store, name: "Other")]
            )
          end

          let!(:main_method) do
            create(
              :shipping_method,
              cost: 5.00,
              stores: [order.store]
            )
          end

          it "does not return the other rate at all" do
            expect(subject.shipping_rates(package).map(&:shipping_method_id)).to eq([main_method.id])
          end

          it "doesn't select the other rate even if it's more affordable" do
            expect(subject.shipping_rates(package).map(&:selected)).to eq [true]
          end
        end

        context "includes tax adjustments if applicable" do
          let(:zone) { create(:zone, countries: [order.tax_address.country]) }

          let!(:tax_rate) { create(:tax_rate, zone: zone) }

          before do
            shipping_method.update!(tax_category: tax_rate.tax_categories.first)
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
          stub_spree_preferences(shipping_rate_selector_class: selector_class)

          subject.shipping_rates(package)

          expect(shipping_rate.selected).to eq(true)
        end

        it 'uses the configured shipping rate sorter' do
          class Spree::Stock::TestSorter
            def initialize(_rates)
            end
          end

          stub_spree_preferences(shipping_rate_sorter_class: Spree::Stock::TestSorter)

          sorter = double(:sorter, sort: nil)
          allow(Spree::Stock::TestSorter).to receive(:new) { sorter }

          subject.shipping_rates(package)

          expect(sorter).to have_received(:sort)
        end

        it 'uses the configured shipping rate taxer' do
          class Spree::Tax::TestTaxCalculator
            def initialize(_order)
            end

            def calculate(_shipping_rate)
              [
                Spree::Tax::ItemTax.new(label: "TAX", amount: 5)
              ]
            end
          end

          stub_spree_preferences(shipping_rate_tax_calculator_class: Spree::Tax::TestTaxCalculator)

          expect(Spree::Tax::TestTaxCalculator).to receive(:new).and_call_original
          subject.shipping_rates(package)
        end
      end
    end
  end
end
