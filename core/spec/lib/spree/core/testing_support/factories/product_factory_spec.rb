# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/product_factory'

RSpec.describe 'product factory' do
  let(:factory_class) { Spree::Product }

  describe 'plain product' do
    let(:factory) { :product }

    it_behaves_like 'a working factory'
  end

  describe 'base product' do
    let(:factory) { :base_product }

    it_behaves_like 'a working factory'
  end

  describe 'custom product' do
    let(:factory) { :custom_product }

    it_behaves_like 'a working factory'
  end

  describe 'product with option types' do
    let(:factory) { :product_with_option_types }

    it_behaves_like 'a working factory'
  end
end
