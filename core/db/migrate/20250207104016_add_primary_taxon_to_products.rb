class AddPrimaryTaxonToProducts < ActiveRecord::Migration[7.0]
  def change
    change_table :spree_products do |t|
      t.references :primary_taxon, { to_table: :spree_taxons }
    end
  end
end
