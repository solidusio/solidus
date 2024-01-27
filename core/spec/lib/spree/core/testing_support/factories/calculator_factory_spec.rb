# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/working_factory'

RSpec.describe 'calculator factory' do
  let(:factory_class) { Spree::Calculator }

  describe 'calculator' do
    let(:factory) { :calculator }

    it_behaves_like 'a working factory'
  end

  describe 'default_tax_calculator' do
    let(:factory) { :default_tax_calculator }

    it_behaves_like 'a working factory'
  end

  describe 'shipping calculator' do
    let(:factory) { :shipping_calculator }

    it_behaves_like 'a working factory'
  end

  describe 'shipping no amount calculator' do
    let(:factory) { :shipping_no_amount_calculator }

    it_behaves_like 'a working factory'
  end
end
