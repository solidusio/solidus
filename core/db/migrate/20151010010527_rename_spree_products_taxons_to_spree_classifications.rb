class RenameSpreeProductsTaxonsToSpreeClassifications < ActiveRecord::Migration
  def change
    rename_table :spree_products_taxons, :spree_classifications
  end
end
