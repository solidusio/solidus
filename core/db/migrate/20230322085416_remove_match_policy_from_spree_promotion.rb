class RemoveMatchPolicyFromSpreePromotion < ActiveRecord::Migration[5.2]
  def change
    remove_column :spree_promotions, :match_policy, :string, default: "all"
  end
end
