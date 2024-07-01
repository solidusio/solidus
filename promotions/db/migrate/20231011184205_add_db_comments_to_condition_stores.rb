# frozen_string_literal: true

class AddDbCommentsToConditionStores < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_condition_stores, solidus_promotions_condition_stores_table_comment)
      change_column_comment(:solidus_promotions_condition_stores, :id, id_comment)
      change_column_comment(:solidus_promotions_condition_stores, :store_id, store_id_comment)
      change_column_comment(:solidus_promotions_condition_stores, :condition_id, condition_id_comment)
      change_column_comment(:solidus_promotions_condition_stores, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_condition_stores, :updated_at, updated_at_comment)
    end
  end

  private

  def solidus_promotions_condition_stores_table_comment
    <<~COMMENT
      Join table between conditions and stores. Only used with the condition "Store", which checks that an order
      has been placed in a particular Spree::Store instance.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def store_id_comment
    <<~COMMENT
      Foreign key to the spree_stores table.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the solidus_promotions_promotion_rules table.
    COMMENT
  end

  def created_at_comment
    <<~COMMENT
      Timestamp indicating when this record was created.
    COMMENT
  end

  def updated_at_comment
    <<~COMMENT
      Timestamp indicating when this record was last updated.
    COMMENT
  end
end
