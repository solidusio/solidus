# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/variant_property_rule_condition_factory'

RSpec.describe 'variant property rule condition factory' do
  let(:factory_class) { Spree::VariantPropertyRuleCondition }

  describe 'variant property rule condition' do
    let(:factory) { :variant_property_rule_condition }

    it_behaves_like 'a working factory'
  end
end
