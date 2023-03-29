# frozen_string_literal: true

require "spree/migration"

class AddDiscontinueOnToSpreeProducts < Spree::Migration
  def change
    add_column :spree_products, :discontinue_on, :datetime
  end
end
