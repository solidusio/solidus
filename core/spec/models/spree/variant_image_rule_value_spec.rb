require 'spec_helper'

describe Spree::VariantImageRuleValue, type: :model do
  describe "callbacks" do
    context "touching" do
      let(:rule_value) { create(:variant_image_rule_value) }
      let(:rule) { rule_value.variant_image_rule }

      before do
        rule.update_columns(updated_at: 1.day.ago)
      end

      subject { rule_value.touch }

      it "touches the variant image rule" do
        expect { subject }.to change { rule.reload.updated_at }
      end
    end

    context "destroying" do
      let(:rule) { create(:variant_image_rule) }
      let!(:rule_value) { rule.values.first }

      subject { rule_value.destroy }

      context "value's rule doesn't have any more values" do
        it "destroys the value's rule" do
          expect { subject }.to change { Spree::VariantImageRule.count }.by(-1)
        end
      end

      context "value's rule still has other values" do
        let!(:second_rule_value) do
          create(:variant_image_rule_value, variant_image_rule: rule_value.variant_image_rule)
        end

        it "doesn't destroy the value's rule" do
          expect { subject }.to_not change { Spree::VariantImageRule.count }
        end
      end
    end
  end
end
