require 'spec_helper'
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
