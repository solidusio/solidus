class RemoveSolidusConfigurations < ActiveRecord::Migration
  def up
    drop_table :solidus_configurations
  end

  def down
    create_table :solidus_configurations do |t|
      t.string     :name
      t.string     :type, :limit => 50
      t.timestamps null: true
    end

    add_index :solidus_configurations, [:name, :type], :name => 'index_solidus_configurations_on_name_and_type'
  end
end
