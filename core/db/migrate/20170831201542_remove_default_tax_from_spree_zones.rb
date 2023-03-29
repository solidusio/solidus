# frozen_string_literal: true

require "spree/migration"

class RemoveDefaultTaxFromSpreeZones < Spree::Migration
  def change
    remove_column :spree_zones, :default_tax, :boolean, default: false
  end
end
