require 'spec_helper'

describe Spree::VariantPropertyRuleValue, type: :model do
  context "touching" do
    let(:rule_value) { create(:variant_property_rule_value) }
    let(:rule) { rule_value.variant_property_rule }

    subject { rule_value.touch }

    it "touches the variant property rule" do
      expect { subject }.to change { rule.reload.updated_at }
    end
  end
end
