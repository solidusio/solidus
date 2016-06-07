class CreateSpreeTaxonHierarchies < ActiveRecord::Migration
  def change
    create_table :spree_taxon_hierarchies do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :spree_taxon_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: "spree_taxon_anc_desc_idx"

    add_index :spree_taxon_hierarchies, [:descendant_id],
              name: "spree_taxon_desc_idx"
  end
end
