require 'spec_helper'

describe Spree::VariantImageRule, type: :model do
  context "touching" do
    let(:rule) { create(:variant_image_rule) }

    before do
      rule.product.update_columns(updated_at: 1.day.ago)
    end

    it "should update the product" do
      expect { rule.touch }.to change { rule.reload.product.updated_at }
    end
  end

  describe "#applies_to_variant?" do
    let(:variant_option_value_1) { create(:option_value) }
    let(:variant_option_value_2) { create(:option_value) }
    let!(:variant) { create(:variant, option_values: option_values)}
    let(:rule) { create(:variant_image_rule, option_value: rule_option_value) }

    subject { rule.applies_to_variant?(variant) }

    context "rule has conditions" do
      let(:rule_option_value) { create(:option_value) }
      let!(:rule_condition_1) { create(:variant_image_rule_condition, variant_image_rule: rule, option_value: variant_option_value_1) }
      let!(:rule_condition_2) { create(:variant_image_rule_condition, variant_image_rule: rule, option_value: variant_option_value_2) }

      context "variant matches some of the rule's conditions" do
        let(:option_values) { [variant_option_value_1, variant_option_value_2] }

        it { is_expected.to eq false }
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

    context "rule doesn't have any conditions" do
      let(:rule_option_value) { nil }
      let(:option_values) { [create(:option_value)] }

      it { is_expected.to eq true }
    end
  end
end
