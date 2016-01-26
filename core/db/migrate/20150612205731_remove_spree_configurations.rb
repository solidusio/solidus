class RemoveSpreeConfigurations < ActiveRecord::Migration
  def up
    drop_table :spree_configurations
  end

  def down
    create_table :spree_configurations do |t|
      t.string     :name
      t.string     :type, limit: 50
      t.timestamps null: true
    end

    add_index :spree_configurations, [:name, :type], name: 'index_spree_configurations_on_name_and_type'
  end
end
