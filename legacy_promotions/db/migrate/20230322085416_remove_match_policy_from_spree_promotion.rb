class RemoveMatchPolicyFromSpreePromotion < ActiveRecord::Migration[5.2]
  def change
    if column_exists?(:spree_promotions, :match_policy)
      remove_column :spree_promotions, :match_policy, :string, default: "all"
    end
  end
end
