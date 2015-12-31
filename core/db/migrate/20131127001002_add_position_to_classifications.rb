class AddPositionToClassifications < ActiveRecord::Migration
  def change
    add_column :solidus_products_taxons, :position, :integer
  end
end
