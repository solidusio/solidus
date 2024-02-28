class RemoveMatchPolicyFromSpreePromotion < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_promotions, :match_policy, :string, default: "all", if_exists: true
  end
end
