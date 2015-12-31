class RemoveValueTypeFromSolidusPreferences < ActiveRecord::Migration
  def up
    remove_column :solidus_preferences, :value_type
  end
  def down
    raise ActiveRecord::IrreversableMigration
  end
end
