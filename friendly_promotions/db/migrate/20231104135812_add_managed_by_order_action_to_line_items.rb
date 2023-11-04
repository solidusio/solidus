class AddManagedByOrderActionToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_line_items, :managed_by_order_action, foreign_key: {to_table: :friendly_promotion_actions, null: true}
  end
end
