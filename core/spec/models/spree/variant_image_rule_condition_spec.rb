require 'spec_helper'

describe Spree::VariantImageRuleCondition, type: :model do
  context "touching" do
    let(:rule_condition) { create(:variant_image_rule_condition) }

    before do
      rule_condition.variant_image_rule.update_columns(updated_at: 1.day.ago)
    end

    it "should update the variant image rule" do
      expect { rule_condition.touch }.to change { rule_condition.reload.variant_image_rule.updated_at }
    end
  end
end
