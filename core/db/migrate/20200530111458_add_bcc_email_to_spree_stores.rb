# frozen_string_literal: true

class AddBccEmailToSpreeStores < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_stores, :bcc_email, :string
  end
end
