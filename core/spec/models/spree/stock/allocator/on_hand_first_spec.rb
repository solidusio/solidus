# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    module Allocator
      RSpec.describe OnHandFirst, type: :model do
        subject { described_class.new(availability) }

        let(:availability) { double(Spree::Stock::Availability) }

        let!(:default_stock_location) { create(:stock_location, default: true, backorderable_default: false) }
        let!(:backorderable_stock_location) { create(:stock_location) }

        let(:first_variant) { create(:variant) }
        let(:second_variant) { create(:variant) }

        let(:desired_quantities) do
          quantities = {}
          quantities[first_variant] = first_variant_desired
          quantities[second_variant] = second_variant_desired
          quantities
        end

        let(:desired) { Spree::StockQuantities.new(desired_quantities) }

        describe '#allocate_inventory' do
          let(:default_on_hand_availability) do
            quantities = {}
            quantities[first_variant] = first_variant_default_availability
            quantities[second_variant] = second_variant_default_availability
            quantities
          end

          let(:dropship_on_hand_availability) do
            quantities = {}
            quantities[first_variant] = first_variant_dropship_availability
            quantities[second_variant] = second_variant_dropship_availability
            quantities
          end

          let(:on_hand_by_stock_location_id) do
            availability = {}
            availability[default_stock_location.id] = Spree::StockQuantities.new(default_on_hand_availability)
            availability[backorderable_stock_location.id] = Spree::StockQuantities.new(dropship_on_hand_availability)
            availability
          end

          let(:dropship_backorderable_availability) do
            quantities = {}
            quantities[first_variant] = Float::INFINITY
            quantities[second_variant] = Float::INFINITY
            quantities
          end

          let(:backorderable_by_stock_location_id) do
            availability = {}
            availability[backorderable_stock_location.id] = Spree::StockQuantities.new(dropship_backorderable_availability)
            availability
          end

          before do
            allow(availability).to receive(:on_hand_by_stock_location_id)
              .and_return(on_hand_by_stock_location_id)

            allow(availability).to receive(:backorderable_by_stock_location_id)
              .and_return(backorderable_by_stock_location_id)
          end

          context 'when default stock location has enough items' do
            let(:first_variant_default_availability) { 100 }
            let(:second_variant_default_availability) { 100 }
            let(:first_variant_dropship_availability) { 0 }
            let(:second_variant_dropship_availability) { 0 }
            let(:first_variant_desired) { 30 }
            let(:second_variant_desired) { 5 }

            it 'allocates all the desired units on the default stock location' do
              on_hand_packages, backordered_packages, leftover = subject.allocate_inventory(desired)

              expect(on_hand_packages[default_stock_location.id][first_variant]).to eq(30)
              expect(on_hand_packages[default_stock_location.id][second_variant]).to eq(5)
              expect(on_hand_packages[backorderable_stock_location.id][first_variant]).to eq(0)
              expect(on_hand_packages[backorderable_stock_location.id][second_variant]).to eq(0)

              expect(backordered_packages[backorderable_stock_location.id][first_variant]).to eq(0)
              expect(backordered_packages[backorderable_stock_location.id][second_variant]).to eq(0)

              expect(leftover[first_variant]).to eq(0)
              expect(leftover[second_variant]).to eq(0)
            end
          end

          context 'when default stock location hasn\'t enough items' do
            let(:first_variant_default_availability) { 10 }
            let(:second_variant_default_availability) { 10 }

            let(:first_variant_desired) { 15 }
            let(:second_variant_desired) { 5 }

            context 'when dropship stock location has enough items' do
              let(:first_variant_dropship_availability) { 20 }
              let(:second_variant_dropship_availability) { 0 }

              it 'allocates all the desired units on the stock locations while stocks last' do
                on_hand_packages, backordered_packages, leftover = subject.allocate_inventory(desired)

                expect(on_hand_packages[default_stock_location.id][first_variant]).to eq(10)
                expect(on_hand_packages[default_stock_location.id][second_variant]).to eq(5)
                expect(on_hand_packages[backorderable_stock_location.id][first_variant]).to eq(5)
                expect(on_hand_packages[backorderable_stock_location.id][second_variant]).to eq(0)

                expect(backordered_packages[backorderable_stock_location.id][first_variant]).to eq(0)
                expect(backordered_packages[backorderable_stock_location.id][second_variant]).to eq(0)

                expect(leftover[first_variant]).to eq(0)
                expect(leftover[second_variant]).to eq(0)
              end
            end

            context 'when dropship stock location hasn\'t enough items' do
              let(:first_variant_dropship_availability) { 2 }
              let(:second_variant_dropship_availability) { 0 }

              it 'allocates all the desired units on the stock locations while stocks last' do
                on_hand_packages, backordered_packages, leftover = subject.allocate_inventory(desired)

                expect(on_hand_packages[default_stock_location.id][first_variant]).to eq(10)
                expect(on_hand_packages[default_stock_location.id][second_variant]).to eq(5)
                expect(on_hand_packages[backorderable_stock_location.id][first_variant]).to eq(2)
                expect(on_hand_packages[backorderable_stock_location.id][second_variant]).to eq(0)

                expect(backordered_packages[backorderable_stock_location.id][first_variant]).to eq(3)
                expect(backordered_packages[backorderable_stock_location.id][second_variant]).to eq(0)

                expect(leftover[first_variant]).to eq(0)
                expect(leftover[second_variant]).to eq(0)
              end
            end
          end
        end
      end
    end
  end
end
