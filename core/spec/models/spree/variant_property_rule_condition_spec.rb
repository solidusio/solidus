# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::VariantPropertyRuleCondition, type: :model do
  context "touching" do
    let(:rule_condition) { create(:variant_property_rule_condition) }

    before do
      rule_condition.variant_property_rule.update_columns(updated_at: 1.day.ago)
    end

    it "should update the variant property rule" do
      expect { rule_condition.touch }.to change { rule_condition.reload.variant_property_rule.updated_at }
    end
  end
end
