class DropReceivedAtOnReturnItems < ActiveRecord::Migration
  def up
    remove_column :solidus_return_items, :received_at
  end

  def down
    add_column :solidus_return_items, :received_at, :datetime
  end
end
