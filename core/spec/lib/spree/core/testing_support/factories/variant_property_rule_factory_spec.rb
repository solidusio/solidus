# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/variant_property_rule_factory'

RSpec.describe 'variant property rule factory' do
  let(:factory_class) { Spree::VariantPropertyRule }

  describe 'variant property rule' do
    let(:factory) { :variant_property_rule }

    it_behaves_like 'a working factory'
  end
end
