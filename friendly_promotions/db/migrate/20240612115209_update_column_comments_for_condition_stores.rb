class UpdateColumnCommentsForConditionStores < ActiveRecord::Migration[7.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_condition_stores, friendly_condition_stores_table_comment)
      change_column_comment(:friendly_condition_stores, :condition_id, condition_id_comment)
    end
  end

  private

  def friendly_condition_stores_table_comment
    <<~COMMENT
      Join table between conditions and stores. Only used with the condition "Store", which checks that an order
      has been placed in a particular Spree::Store instance.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the friendly_conditions table.
    COMMENT
  end
end
