class AddParentIdToSpreeTaxons < ActiveRecord::Migration
  def change
    unless column_exists?(:spree_taxons, :parent_id)
      add_column :spree_taxons, :parent_id, :integer
    end
  end
end
