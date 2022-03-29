# frozen_string_literal: true

class AddPriorityToSpreePromotions < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_promotions, :priority, :integer
    sql = <<~SQL
      UPDATE spree_promotions
      SET priority = id
    SQL
    execute(sql)
    change_column :spree_promotions, :priority, :integer, null: false
  end

  def down
    remove_column :spree_promotions, :priority, :integer, null: false
  end
end
