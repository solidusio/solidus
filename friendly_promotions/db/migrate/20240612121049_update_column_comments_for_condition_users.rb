class UpdateColumnCommentsForConditionUsers < ActiveRecord::Migration[7.0]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_condition_users, friendly_condition_users_table_comment)
      change_column_comment(:friendly_condition_users, :condition_id, condition_id_comment)
    end
  end

  private

  def friendly_condition_users_table_comment
    <<~COMMENT
      Join table between promotion conditions and users. Used with promotion conditions of type "SolidusFriendlyPromotions::Conditions::User".
      An entry here indicates that a promotion is eligible for the user ID specified here.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the friendly_conditions table.
    COMMENT
  end
end
