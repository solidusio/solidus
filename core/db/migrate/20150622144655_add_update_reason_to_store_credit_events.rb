class AddUpdateReasonToStoreCreditEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_store_credit_events, :update_reason_id, :integer
  end
end
