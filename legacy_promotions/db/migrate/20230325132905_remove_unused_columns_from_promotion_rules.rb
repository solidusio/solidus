class RemoveUnusedColumnsFromPromotionRules < ActiveRecord::Migration[5.2]
  def change
    remove_column :spree_promotion_rules, :code, :string

    remove_column :spree_promotion_rules, :product_group_id, :integer
  end
end
