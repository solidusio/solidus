class AddUpdatedAtToSolidusStates < ActiveRecord::Migration
  def up
    add_column :solidus_states, :updated_at, :datetime
  end

  def down
    remove_column :solidus_states, :updated_at
  end
end
