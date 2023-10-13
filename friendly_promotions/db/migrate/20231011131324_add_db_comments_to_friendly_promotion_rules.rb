# frozen_string_literal: true

class AddDbCommentsToFriendlyPromotionRules < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_promotion_rules, friendly_promotion_rules_table_comment)
      change_column_comment(:friendly_promotion_rules, :id, id_comment)
      change_column_comment(:friendly_promotion_rules, :promotion_id, promotion_id_comment)
      change_column_comment(:friendly_promotion_rules, :type, type_comment)
      change_column_comment(:friendly_promotion_rules, :created_at, created_at_comment)
      change_column_comment(:friendly_promotion_rules, :updated_at, updated_at_comment)
      change_column_comment(:friendly_promotion_rules, :preferences, preferences_comment)
    end
  end

  private

  def friendly_promotion_rules_table_comment
    <<~COMMENT
      Represents promotion rules. A promotion may have many rules, which determine whether the promotion is eligible.
      All rules must be eligible for the promotion to be eligible. If there are no rules, the promotion is always eligible.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def promotion_id_comment
    <<~COMMENT
      Foreign key to the promotions table.
    COMMENT
  end

  def type_comment
    <<~COMMENT
      STI column. This represents which Ruby class to load when an entry of this table is loaded in Rails.
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

  def preferences_comment
    <<~COMMENT
      Preferences for this promotion rule. Serialized YAML column with preferences for this promotion rule.
    COMMENT
  end
end
