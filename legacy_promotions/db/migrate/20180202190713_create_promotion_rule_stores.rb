# frozen_string_literal: true

class CreatePromotionRuleStores < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_promotion_rules_stores, if_not_exists: true do |t|
      t.references :store, null: false
      t.references :promotion_rule, null: false

      t.timestamps
    end
  end
end
