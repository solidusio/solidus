class AddUpdateReasonToStoreCreditEvents < ActiveRecord::Migration
  def change
    add_column :solidus_store_credit_events, :update_reason_id, :integer
  end
end
