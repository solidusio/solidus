require 'spec_helper'

describe Spree::VariantPropertyRuleCondition, type: :model do
  context "touching" do
    it "should update the variant property rule" do
      rule_condition = create(:variant_property_rule_condition)
      expect { rule_condition.touch }.to change { rule_condition.reload.variant_property_rule.updated_at }
    end
  end
end
