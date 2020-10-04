# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/product_option_type_factory'

RSpec.describe 'product option type factory' do
  let(:factory_class) { Spree::ProductOptionType }

  describe 'plain product option type' do
    let(:factory) { :product_option_type }

    it_behaves_like 'a working factory'
  end
end
