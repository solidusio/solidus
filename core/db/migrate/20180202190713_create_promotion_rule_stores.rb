# frozen_string_literal: true

require "spree/migration"

class CreatePromotionRuleStores < Spree::Migration
  def change
    create_table :spree_promotion_rules_stores do |t|
      t.references :store, null: false
      t.references :promotion_rule, null: false

      t.timestamps
    end
  end
end
