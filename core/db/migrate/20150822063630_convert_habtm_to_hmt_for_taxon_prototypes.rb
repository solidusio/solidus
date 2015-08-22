class ConvertHabtmToHmtForTaxonPrototypes < ActiveRecord::Migration
  def up
    add_column :spree_taxons_prototypes, :created_at, :datetime
    add_column :spree_taxons_prototypes, :updated_at, :datetime

    rename_table :spree_taxons_prototypes, :spree_prototype_taxons
  end

  def down
    rename_table :spree_prototype_taxons, :spree_taxons_prototypes

    remove_column :spree_taxons_prototypes, :created_at, :datetime
    remove_column :spree_taxons_prototypes, :updated_at, :datetime
  end
end
