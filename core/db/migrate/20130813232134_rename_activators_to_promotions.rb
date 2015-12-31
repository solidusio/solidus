class RenameActivatorsToPromotions < ActiveRecord::Migration
  def change
    rename_table :solidus_activators, :solidus_promotions
  end
end
