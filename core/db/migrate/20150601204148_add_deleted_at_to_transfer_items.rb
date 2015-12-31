class AddDeletedAtToTransferItems < ActiveRecord::Migration
  def change
    add_column :solidus_transfer_items, :deleted_at, :datetime
  end
end
