class AddInvalidatedAtToSpreeStoreCredits < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_store_credits, :invalidated_at, :datetime
  end
end
