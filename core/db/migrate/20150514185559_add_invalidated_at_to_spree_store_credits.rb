class AddInvalidatedAtToSolidusStoreCredits < ActiveRecord::Migration
  def change
    add_column :solidus_store_credits, :invalidated_at, :datetime
  end
end
