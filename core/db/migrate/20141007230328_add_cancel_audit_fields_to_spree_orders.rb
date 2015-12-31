class AddCancelAuditFieldsToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :canceled_at, :datetime
    add_column :solidus_orders, :canceler_id, :integer
  end
end
