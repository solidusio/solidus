# frozen_string_literal: true

class AddDbCommentsToFriendlyProductsPromotionRules < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_products_promotion_rules, friendly_products_promotion_rules_table_comment)
      change_column_comment(:friendly_products_promotion_rules, :id, id_comment)
      change_column_comment(:friendly_products_promotion_rules, :product_id, product_id_comment)
      change_column_comment(:friendly_products_promotion_rules, :promotion_rule_id, promotion_rule_id_comment)
      change_column_comment(:friendly_products_promotion_rules, :created_at, created_at_comment)
      change_column_comment(:friendly_products_promotion_rules, :updated_at, updated_at_comment)
    end
  end

  private

  def friendly_products_promotion_rules_table_comment
    <<~COMMENT
      Join table between promotion rules and products.
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

  def promotion_rule_id_comment
    <<~COMMENT
      Foreign key to the friendly_promotion_rules table.
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
