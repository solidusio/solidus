class AddDeletedAtToPromotions < ActiveRecord::Migration[7.0]
  def change
    add_column :friendly_promotions, :deleted_at, :datetime
    add_index :friendly_promotions, :deleted_at
  end
end
