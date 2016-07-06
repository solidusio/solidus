class AddIdToSpreeOptionValuesVariants < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_option_values_variants, :id, :primary_key
  end
end
