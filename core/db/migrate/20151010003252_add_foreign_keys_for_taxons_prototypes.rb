class AddForeignKeysForTaxonsPrototypes < ActiveRecord::Migration
  def change
    add_foreign_key :solidus_prototype_taxons, :solidus_taxons, column: :taxon_id
    add_foreign_key :solidus_prototype_taxons, :solidus_prototypes, column: :prototype_id
  end
end
