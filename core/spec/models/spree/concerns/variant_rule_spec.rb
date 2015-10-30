require 'spec_helper'

module Spree
  describe VariantRule do
    #
    # Using VariantPropertyRule as a subject
    # since it includes the VariantRule concern
    #
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

    describe "#applies_to_option_value_ids?" do
      let(:variant_option_value_1) { create(:option_value) }
      let(:variant_option_value_2) { create(:option_value) }
      let!(:variant) { create(:variant, option_values: option_values)}

      let(:rule_option_value) { create(:option_value) }
      let(:rule) { create(:variant_property_rule, option_value: rule_option_value) }
      let!(:rule_condition_1) { create(:variant_property_rule_condition, variant_property_rule: rule, option_value: variant_option_value_1) }
      let!(:rule_condition_2) { create(:variant_property_rule_condition, variant_property_rule: rule, option_value: variant_option_value_2) }

      subject { rule.applies_to_option_value_ids?(variant.option_value_ids) }

      context "ids matches some of the rule's option_value_ids" do
        let(:option_values) { [variant_option_value_1, variant_option_value_2] }

        it { is_expected.to eq false }
      end

      context "none of the ids are included in the rule's option_value_ids" do
        let(:option_values) { [create(:option_value)] }

        it { is_expected.to eq false }
      end

      context "ids match all of the rule's option_value_ids" do
        let(:option_values) { [rule_option_value, variant_option_value_1, variant_option_value_2] }

        it { is_expected.to eq true }
      end
    end
  end
end
