# frozen_string_literal: true

require "spree/migration"

class AddBccEmailToSpreeStores < Spree::Migration
  def change
    add_column :spree_stores, :bcc_email, :string
  end
end
