class ConvertHabtmToHmtForPropertiesPrototypes < ActiveRecord::Migration
  def up
    add_column :solidus_properties_prototypes, :id, :primary_key
    add_column :solidus_properties_prototypes, :created_at, :datetime
    add_column :solidus_properties_prototypes, :updated_at, :datetime

    rename_table :solidus_properties_prototypes, :solidus_property_prototypes
  end

  def down
    rename_table :solidus_property_prototypes, :solidus_properties_prototypes

    remove_column :solidus_properties_prototypes, :id, :primary_key
    remove_column :solidus_properties_prototypes, :created_at, :datetime
    remove_column :solidus_properties_prototypes, :updated_at, :datetime
  end
end
