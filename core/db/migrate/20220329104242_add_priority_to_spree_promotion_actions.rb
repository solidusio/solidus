# frozen_string_literal: true

class AddPriorityToSpreePromotionActions < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_promotion_actions, :priority, :integer
    sql = <<~SQL
      UPDATE spree_promotion_actions
      SET priority = id
    SQL
    execute(sql)
    change_column :spree_promotion_actions, :priority, :integer, null: false
  end

  def down
    remove_column :spree_promotion_actions, :priority, :integer, null: false
  end
end
