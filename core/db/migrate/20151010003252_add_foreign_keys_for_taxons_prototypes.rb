class AddForeignKeysForTaxonsPrototypes < ActiveRecord::Migration
  def change
    { spree_taxons: :taxon_id, spree_prototypes: :prototype_id }.each do |to_table, column|
      add_foreign_key :spree_prototype_taxons, to_table, column: column, on_delete: :cascade
    end
  end
end
