class AddActionReferenceToRules < ActiveRecord::Migration[7.0]
  class LocalBenefit < ApplicationRecord
    self.table_name = "friendly_promotion_actions"
    has_many :actions, class_name: "SolidusFriendlyPromotions::Condition", foreign_key: :action_id
  end

  def up
    remove_foreign_key :friendly_promotion_rules, :friendly_promotions
    change_column :friendly_promotion_rules, :promotion_id, :integer, null: true

    add_reference :friendly_promotion_rules, :action, index: {name: :rule}, null: true, foreign_key: {to_table: :friendly_promotion_actions}

    SolidusFriendlyPromotions::Condition.reset_column_information

    LocalBenefit.find_each do |action|
      SolidusFriendlyPromotions::Condition.where(promotion_id: action.promotion_id).each do |rule|
        rule.dup.tap do |new_rule|
          new_rule.preload_relations.each do |relation|
            new_rule.send(:"#{relation}=", rule.send(relation).dup)
          end
          new_rule.action = action
          new_rule.save!
        end
        rule.destroy!
      end
    end
  end

  def down
    SolidusFriendlyPromotions::Condition.where.not(action_id: nil).delete_all
    change_column :friendly_promotion_rules, :promotion_id, :integer, null: true
    add_foreign_key :friendly_promotion_rules, :friendly_promotions, column: :promotion_id
  end
end
