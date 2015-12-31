class ConvertHabtmToHmtForOptionTypePrototypes < ActiveRecord::Migration
  def up
    add_column :solidus_option_types_prototypes, :id, :primary_key
    add_column :solidus_option_types_prototypes, :created_at, :datetime
    add_column :solidus_option_types_prototypes, :updated_at, :datetime

    rename_table :solidus_option_types_prototypes, :solidus_option_type_prototypes
  end

  def down
    remove_column :solidus_option_types_prototypes, :id
    remove_column :solidus_option_types_prototypes, :created_at
    remove_column :solidus_option_types_prototypes, :updated_at

    rename_table :solidus_option_type_prototypes, :solidus_option_types_prototypes
  end
end
