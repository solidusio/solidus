# frozen_string_literal: true

require "spree/migration"

class AddLftAndRgtIndexesToTaxons < Spree::Migration
  def change
    add_index :spree_taxons, :lft
    add_index :spree_taxons, :rgt
  end
end
