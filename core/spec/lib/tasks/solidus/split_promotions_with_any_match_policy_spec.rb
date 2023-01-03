# frozen_string_literal: true

require 'rails_helper'

path = Spree::Core::Engine.root.join('lib/tasks/solidus/split_promotions_with_any_match_policy.rake')

RSpec.describe 'solidus' do
  describe 'split_promotions_with_any_match_policy' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:split_promotions_with_any_match_policy'
    )
    let(:rule_1) { Spree::Promotion::Rules::Product.new }
    let(:rule_2) { Spree::Promotion::Rules::Product.new }
    let(:rule_3) { Spree::Promotion::Rules::Product.new }
    let(:rule_4) { Spree::Promotion::Rules::Product.new }
    let!(:promotion_with_all_match_policy) { create(:promotion, :with_action, promotion_rules: [rule_1, rule_2]) }
    let!(:promotion_with_any_match_policy) { create(:promotion, :with_action, match_policy: "any", promotion_rules: [rule_3, rule_4]) }

    subject { task.invoke }
    it 'does not touch promotions with an all match policy' do
      expect { task.invoke }.not_to change(promotion_with_all_match_policy, :expires_at)
    end

    it "replaces promotions with any match policy with new ones, one for each rule" do
      expect { task.invoke }.to change { promotion_with_any_match_policy.reload.expires_at }.from(nil)

      expect(Spree::Promotion.count).to eq(4)
      expect(promotion_with_any_match_policy.expires_at).to be_present
      expect(promotion_with_any_match_policy.rules).to be_empty
      expect((Spree::Promotion.all - [promotion_with_all_match_policy, promotion_with_any_match_policy]).flat_map(&:rules)).to match_array([rule_3, rule_4])
    end
  end
end

