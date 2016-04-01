require 'spec_helper'
require 'spree/testing_support/factories/inventory_unit_factory'

RSpec.describe 'inventory unit factory' do
  let(:factory_class) { Spree::InventoryUnit }

  describe 'plain inventory unit' do
    let(:factory) { :inventory_unit }

    it_behaves_like 'a working factory'
  end

  describe 'with passed in variant' do
    let(:variant) { build(:variant) }
    subject { build(:inventory_unit, variant: variant) }
    it "has a line_item with proper price" do
      expect(subject.line_item.price).to eq(variant.price)
    end
  end
end
