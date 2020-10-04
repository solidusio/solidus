# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/variant_property_rule_value_factory'

RSpec.describe 'variant property rule value factory' do
  let(:factory_class) { Spree::VariantPropertyRuleValue }

  describe 'variant property rule value' do
    let(:factory) { :variant_property_rule_value }

    it_behaves_like 'a working factory'
  end
end
