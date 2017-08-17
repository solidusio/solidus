require 'spec_helper'

module Spree
  module Stock
    module Splitter
      describe Backordered, type: :model do
        let(:variant) { build(:variant) }
        let(:order) { build(:order) }

        let(:packer) { build(:stock_packer, order: order) }

        subject { Backordered.new(packer) }

        it 'splits packages by status' do
          package = Package.new(order, packer.stock_location)
          4.times { package.add build(:inventory_unit, variant: variant) }
          5.times { package.add build(:inventory_unit, variant: variant), :backordered }

          packages = subject.split([package])
          expect(packages.count).to eq 2
          expect(packages.first.quantity).to eq 4
          expect(packages.first.on_hand.count).to eq 4
          expect(packages.first.backordered.count).to eq 0

          expect(packages[1].contents.count).to eq 5
        end
      end
    end
  end
end
