class AddBrandTaxonToProducts < ActiveRecord::Migration[7.0]
  def change
    change_table :spree_products do |t|
      t.references :brand_taxon, type: :integer, foreign_key: { to_table: :spree_taxons }
    end
  end
end
