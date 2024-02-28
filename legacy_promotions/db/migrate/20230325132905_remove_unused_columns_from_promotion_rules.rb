class RemoveUnusedColumnsFromPromotionRules < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_promotion_rules, :code, :string, if_exists: true

    remove_column :spree_promotion_rules, :product_group_id, :integer, if_exists: true
  end
end
