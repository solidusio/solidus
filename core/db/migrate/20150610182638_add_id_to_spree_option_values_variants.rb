class AddIdToSpreeOptionValuesVariants < ActiveRecord::Migration
  def change
    add_column :solidus_option_values_variants, :id, :primary_key
  end
end
