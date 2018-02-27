class AddStoreCreditExpiresAt < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_store_credits, :expires_at, :datetime
  end
end
