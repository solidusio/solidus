# frozen_string_literal: true

class AddFkToClassifications < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :spree_products_taxons, :spree_products, column: :product_id
    add_foreign_key :spree_products_taxons, :spree_taxons, column: :taxon_id
  end
end
