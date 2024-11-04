# frozen_string_literal: true

class AddDbCommentsToConditionUsers < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_condition_users, solidus_promotions_condition_users_table_comment)
      change_column_comment(:solidus_promotions_condition_users, :user_id, user_id_comment)
      change_column_comment(:solidus_promotions_condition_users, :condition_id, condition_id_comment)
      change_column_comment(:solidus_promotions_condition_users, :id, id_comment)
      change_column_comment(:solidus_promotions_condition_users, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_condition_users, :updated_at, updated_at_comment)
    end
  end

  private

  def solidus_promotions_condition_users_table_comment
    <<~COMMENT
      Join table between conditions and users. Used with conditions of type "SolidusPromotions::Conditions::User".
      An entry here indicates that a promotion is eligible for the user ID specified here.
    COMMENT
  end

  def user_id_comment
    <<~COMMENT
      Foreign key to the users table.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the conditions table.
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
