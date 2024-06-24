class UpdateColumnCommentsForConditionProducts < ActiveRecord::Migration[7.0]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_condition_products, friendly_condition_products_table_comment)
      change_column_comment(:friendly_condition_products, :condition_id, condition_id_comment)
    end
  end

  private

  def friendly_condition_products_table_comment
    <<~COMMENT
      Join table between promotion conditions and products.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the friendly_conditions table.
    COMMENT
  end
end
