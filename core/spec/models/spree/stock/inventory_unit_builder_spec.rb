# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe InventoryUnitBuilder, type: :model do
      let(:line_item_1) { build(:line_item) }
      let(:line_item_2) { build(:line_item, quantity: 2) }
      let(:order) { build(:order, line_items: [line_item_1, line_item_2]) }

      subject { InventoryUnitBuilder.new(order) }

      describe "#units" do
        it "returns an inventory unit for each quantity for the order's line items" do
          units = subject.units
          expect(units.count).to eq 3
          expect(units.first.line_item).to eq line_item_1
          expect(units.first.variant).to eq line_item_1.variant

          expect(units[1].line_item).to eq line_item_2
          expect(units[1].variant).to eq line_item_2.variant

          expect(units[2].line_item).to eq line_item_2
          expect(units[2].variant).to eq line_item_2.variant
        end

        it "builds the inventory units as pending" do
          expect(subject.units.map(&:pending).uniq).to eq [true]
        end
      end

      describe '#missing_units_for_line_item' do
        context 'when all inventory units are missing' do
          it 'builds all inventory units for the line item' do
            units = subject.missing_units_for_line_item(line_item_2)
            expect(units.size).to be 2
            expect(units).to be_all { |unit| unit.line_item == line_item_2 }
          end
        end

        context 'when some inventory units are already present' do
          before do
            line_item_2.inventory_units << build(:inventory_unit)
            line_item_2.save!
          end

          it 'builds only the missing inventory unit' do
            units = subject.missing_units_for_line_item(line_item_2)
            expect(units.size).to be 1
            expect(units.first.line_item).to eql line_item_2
          end
        end
      end
    end
  end
end
