# frozen_string_literal: true

class AddDbCommentsToFriendlyPromotionRulesUsers < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_promotion_rules_users, friendly_promotion_rules_users_table_comment)
      change_column_comment(:friendly_promotion_rules_users, :user_id, user_id_comment)
      change_column_comment(:friendly_promotion_rules_users, :promotion_rule_id, promotion_rule_id_comment)
      change_column_comment(:friendly_promotion_rules_users, :id, id_comment)
      change_column_comment(:friendly_promotion_rules_users, :created_at, created_at_comment)
      change_column_comment(:friendly_promotion_rules_users, :updated_at, updated_at_comment)
    end
  end

  private

  def friendly_promotion_rules_users_table_comment
    <<~COMMENT
      Join table between promotion rules and users. Used with promotion rules of type "SolidusFriendlyPromotions::Rules::User".
      An entry here indicates that a promotion is eligible for the user ID specified here.
    COMMENT
  end

  def user_id_comment
    <<~COMMENT
      Foreign key to the users table.
    COMMENT
  end

  def promotion_rule_id_comment
    <<~COMMENT
      Foreign key to the promotion_rules table.
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
