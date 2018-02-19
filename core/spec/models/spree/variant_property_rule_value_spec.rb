# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::VariantPropertyRuleValue, type: :model do
  context "touching" do
    let(:rule_value) { create(:variant_property_rule_value) }
    let(:rule) { rule_value.variant_property_rule }

    before do
      rule.update_columns(updated_at: 1.day.ago)
    end

    subject { rule_value.touch }

    it "touches the variant property rule" do
      expect { subject }.to change { rule.reload.updated_at }
    end
  end
end
