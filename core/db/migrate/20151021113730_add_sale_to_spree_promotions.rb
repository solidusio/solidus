class AddSaleToSolidusPromotions < ActiveRecord::Migration
  def change
    add_column :solidus_promotions, :apply_automatically, :boolean, default: false
    add_index :solidus_promotions, :apply_automatically
  end
end
