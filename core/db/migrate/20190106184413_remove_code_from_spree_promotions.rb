# frozen_string_literal: true

class RemoveCodeFromSpreePromotions < ActiveRecord::Migration[5.1]
  def up
    remove_index :spree_promotions, name: :index_spree_promotions_on_code
    remove_column :spree_promotions, :code
  end

  def down
    add_column :spree_promotions, :code, :string
    add_index :spree_promotions, :code, name: :index_spree_promotions_on_code
  end
end
