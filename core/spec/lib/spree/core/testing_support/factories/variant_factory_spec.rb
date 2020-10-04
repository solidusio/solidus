# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/variant_factory'

RSpec.describe 'variant factory' do
  let(:factory_class) { Spree::Variant }

  describe 'base variant' do
    let(:factory) { :base_variant }

    it_behaves_like 'a working factory'
  end

  describe 'variant' do
    let(:factory) { :variant }

    it_behaves_like 'a working factory'
  end

  describe 'master variant' do
    let(:factory) { :master_variant }

    it_behaves_like 'a working factory'

    it "builds a master variant properly" do
      variant = create(factory)
      expect(variant).to be_is_master
      expect(variant.option_values).to be_empty

      product = variant.product
      expect(product.master).to be(variant)
      expect(product.variants).to be_empty
      expect(product.variants_including_master).to eq [variant]
      expect(product.option_types).to be_empty
    end

    it "creates only one variant" do
      expect {
        create(factory)
      }.to change { Spree::Variant.count }.from(0).to(1)
    end
  end

  describe 'on demand variant' do
    let(:factory) { :on_demand_variant }

    it_behaves_like 'a working factory'
  end

  describe 'on demand master variant' do
    let(:factory) { :on_demand_master_variant }

    it_behaves_like 'a working factory'
  end
end
