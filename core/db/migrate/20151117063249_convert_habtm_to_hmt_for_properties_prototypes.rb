class ConvertHabtmToHmtForPropertiesPrototypes < ActiveRecord::Migration
  def up
    add_column :spree_properties_prototypes, :id, :primary_key
    add_column :spree_properties_prototypes, :created_at, :datetime
    add_column :spree_properties_prototypes, :updated_at, :datetime

    rename_table :spree_properties_prototypes, :spree_property_prototypes
  end

  def down
    rename_table :spree_property_prototypes, :spree_properties_prototypes

    remove_column :spree_properties_prototypes, :id, :primary_key
    remove_column :spree_properties_prototypes, :created_at, :datetime
    remove_column :spree_properties_prototypes, :updated_at, :datetime
  end
end
