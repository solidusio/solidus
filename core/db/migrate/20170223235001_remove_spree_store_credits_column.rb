# frozen_string_literal: true

require "spree/migration"

class RemoveSpreeStoreCreditsColumn < Spree::Migration
  def change
    remove_column :spree_store_credits, :spree_store_credits, :datetime
  end
end
