class AddManagedByOrderBenefitToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_line_items, :managed_by_order_benefit, foreign_key: { to_table: :solidus_promotions_benefits, null: true }
  end
end
