# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::VariantPropertyRule, type: :model do
  context "touching" do
    let(:rule) { create(:variant_property_rule) }

    before do
      rule.product.update_columns(updated_at: 1.day.ago)
    end

    it "should update the product" do
      expect { rule.touch }.to change { rule.reload.product.updated_at }
    end
  end

  describe "#matches_option_value_ids?" do
    let(:first_condition_option_value) { create(:option_value) }
    let(:second_condition_option_value) { create(:option_value) }
    let!(:second_condition) do
      create(:variant_property_rule_condition,
        variant_property_rule: rule,
        option_value: second_condition_option_value)
    end
    let(:rule) { create(:variant_property_rule, option_value: first_condition_option_value) }

    context "provided ids are the same as the rule's condition's option value ids" do
      subject do
        rule.matches_option_value_ids?([second_condition_option_value.id, first_condition_option_value.id])
      end

      it { is_expected.to eq true }
    end

    context "some of the provided ids are the same as the rule's condition's option value ids" do
      subject do
        rule.matches_option_value_ids?([first_condition_option_value.id])
      end

      it { is_expected.to eq false }
    end

    context "none of the provided ids are the same as the rule's condition's option value ids" do
      let(:other_option_value) { create(:option_value) }

      subject do
        rule.matches_option_value_ids?([other_option_value.id])
      end

      it { is_expected.to eq false }
    end
  end

  describe "#applies_to_variant?" do
    let(:variant_option_value_1) { create(:option_value) }
    let(:variant_option_value_2) { create(:option_value) }
    let!(:variant) { create(:variant, option_values: option_values) }

    let(:rule_option_value) { create(:option_value) }
    let(:rule) { create(:variant_property_rule, option_value: rule_option_value) }
    let!(:rule_condition_1) { create(:variant_property_rule_condition, variant_property_rule: rule, option_value: variant_option_value_1) }
    let!(:rule_condition_2) { create(:variant_property_rule_condition, variant_property_rule: rule, option_value: variant_option_value_2) }

    subject { rule.applies_to_variant?(variant) }

    context "variant matches some of the rule's conditions" do
      let(:option_values) { [variant_option_value_1, variant_option_value_2] }

      it { is_expected.to eq true }
    end

    context "variant matches none of the rule's conditions" do
      let(:option_values) { [create(:option_value)] }

      it { is_expected.to eq false }
    end

    context "variant matches all of the rule's conditions" do
      let(:option_values) { [rule_option_value, variant_option_value_1, variant_option_value_2] }

      it { is_expected.to eq true }
    end
  end
end
