class ConvertHabtmToHmtForOptionTypePrototypes < ActiveRecord::Migration
  def up
    add_column :spree_option_types_prototypes, :id, :primary_key
    add_column :spree_option_types_prototypes, :created_at, :datetime
    add_column :spree_option_types_prototypes, :updated_at, :datetime

    rename_table :spree_option_types_prototypes, :spree_option_type_prototypes
  end

  def down
    rename_table :spree_option_type_prototypes, :spree_option_types_prototypes

    remove_column :spree_option_types_prototypes, :id
    remove_column :spree_option_types_prototypes, :created_at
    remove_column :spree_option_types_prototypes, :updated_at
  end
end
