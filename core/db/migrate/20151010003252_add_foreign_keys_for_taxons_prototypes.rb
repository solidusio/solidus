class AddForeignKeysForTaxonsPrototypes < ActiveRecord::Migration
  def change
    add_foreign_key :spree_prototype_taxons, :spree_taxons,
                    column: :taxon_id, on_delete: :cascade

    add_foreign_key :spree_prototype_taxons, :spree_prototypes,
                    column: :prototype_id, on_delete: :cascade
  end
end
