class AddPrimaryToSolidusProductsTaxons < ActiveRecord::Migration
  def change
    add_column :solidus_products_taxons, :id, :primary_key
  end
end
