# frozen_string_literal: true

class AddDbCommentsToConditionProducts < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_condition_products, solidus_promotions_condition_products_table_comment)
      change_column_comment(:solidus_promotions_condition_products, :id, id_comment)
      change_column_comment(:solidus_promotions_condition_products, :product_id, product_id_comment)
      change_column_comment(:solidus_promotions_condition_products, :condition_id, condition_id_comment)
      change_column_comment(:solidus_promotions_condition_products, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_condition_products, :updated_at, updated_at_comment)
    end
  end

  private

  def solidus_promotions_condition_products_table_comment
    <<~COMMENT
      Join table between conditions and products.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def product_id_comment
    <<~COMMENT
      Foreign key to the spree_products table.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the solidus_promotions_conditions table.
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
