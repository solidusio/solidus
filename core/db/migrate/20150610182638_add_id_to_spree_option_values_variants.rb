class AddIdToSpreeOptionValuesVariants < ActiveRecord::Migration
  def change
    add_column :spree_option_values_variants, :id, :primary_key
  end
end
