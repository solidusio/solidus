class AddGtinAndConditionToSpreeVariant < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_variants, :gtin, :string
    add_column :spree_variants, :condition, :string
  end
end
