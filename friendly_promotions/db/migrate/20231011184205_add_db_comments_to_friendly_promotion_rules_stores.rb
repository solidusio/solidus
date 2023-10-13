# frozen_string_literal: true

class AddDbCommentsToFriendlyPromotionRulesStores < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_promotion_rules_stores, friendly_promotion_rules_stores_table_comment)
      change_column_comment(:friendly_promotion_rules_stores, :id, id_comment)
      change_column_comment(:friendly_promotion_rules_stores, :store_id, store_id_comment)
      change_column_comment(:friendly_promotion_rules_stores, :promotion_rule_id, promotion_rule_id_comment)
      change_column_comment(:friendly_promotion_rules_stores, :created_at, created_at_comment)
      change_column_comment(:friendly_promotion_rules_stores, :updated_at, updated_at_comment)
    end
  end

  private

  def friendly_promotion_rules_stores_table_comment
    <<~COMMENT
      Join table between promotion rules and stores. Only used with the promotion rule "Store", which checks that an order
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
