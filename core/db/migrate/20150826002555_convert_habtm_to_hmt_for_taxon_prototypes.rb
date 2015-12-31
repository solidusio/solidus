class ConvertHabtmToHmtForTaxonPrototypes < ActiveRecord::Migration
  def up
    add_column :solidus_taxons_prototypes, :created_at, :datetime
    add_column :solidus_taxons_prototypes, :updated_at, :datetime

    rename_table :solidus_taxons_prototypes, :solidus_prototype_taxons
  end

  def down
    rename_table :solidus_prototype_taxons, :solidus_taxons_prototypes

    remove_column :solidus_taxons_prototypes, :created_at, :datetime
    remove_column :solidus_taxons_prototypes, :updated_at, :datetime
  end
end
