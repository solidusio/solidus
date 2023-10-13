# frozen_string_literal: true

class AddDbCommentsToFriendlyOrderPromotions < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_order_promotions, friendly_order_promotions_table_comment)
      change_column_comment(:friendly_order_promotions, :order_id, order_id_comment)
      change_column_comment(:friendly_order_promotions, :promotion_id, promotion_id_comment)
      change_column_comment(:friendly_order_promotions, :promotion_code_id, promotion_code_id_comment)
      change_column_comment(:friendly_order_promotions, :id, id_comment)
      change_column_comment(:friendly_order_promotions, :created_at, created_at_comment)
      change_column_comment(:friendly_order_promotions, :updated_at, updated_at_comment)
    end
  end

  private

  def friendly_order_promotions_table_comment
    <<~COMMENT
      Join table between spree_orders and friendly_promotions. One of two places that record whether a promotion is linked to an order.
      The other place is the spree_adjustments table which records promotion code IDs and could be both eligible and ineligible.
      An entry here is created every time a promotion is linked to an order.
    COMMENT
  end

  def order_id_comment
    <<~COMMENT
      Foreign key to the spree_orders table.
    COMMENT
  end

  def promotion_id_comment
    <<~COMMENT
      Foreign key to the friendly_promotions table.
    COMMENT
  end

  def promotion_code_id_comment
    <<~COMMENT
      Foreign key to the friendly_promotion_codes table. If a promotion code was used, records the promotion code.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
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
