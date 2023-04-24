class ChangeColumnNullOptionValuesOptionTypeId < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:spree_option_values, :option_type_id, false)
  end
end
