# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe Splitter::ShippingCategory, type: :model do
      let(:order) { create(:order_with_line_items, line_items_count: 1) }
      let(:line_item) { order.line_items.first }
      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }
      let(:shipping_category_1) { create(:shipping_category, name: 'A') }
      let(:shipping_category_2) { create(:shipping_category, name: 'B') }

      def inventory_unit1
        build(:inventory_unit, variant: variant1, order: order, line_item: line_item).tap do |inventory_unit|
          inventory_unit.variant.product.shipping_category = shipping_category_1
        end
      end

      def inventory_unit2
        build(:inventory_unit, variant: variant2, order: order, line_item: line_item).tap do |inventory_unit|
          inventory_unit.variant.product.shipping_category = shipping_category_2
        end
      end

      let(:stock_location) { mock_model(Spree::StockLocation) }

      subject { described_class.new(stock_location) }

      it 'splits each package by shipping category' do
        package_one = Package.new(stock_location)
        4.times { package_one.add inventory_unit1 }
        8.times { package_one.add inventory_unit2 }

        package_two = Package.new(stock_location)
        6.times { package_two.add inventory_unit1 }
        9.times { package_two.add inventory_unit2, :backordered }

        packages = subject.split([package_one, package_two])
        expect(packages[0].quantity).to eq 4
        expect(packages[1].quantity).to eq 8
        expect(packages[2].quantity).to eq 6
        expect(packages[3].quantity).to eq 9
      end
    end
  end
end
