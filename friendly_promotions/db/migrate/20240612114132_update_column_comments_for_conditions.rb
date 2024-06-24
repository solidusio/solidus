class UpdateColumnCommentsForConditions < ActiveRecord::Migration[7.0]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_conditions, friendly_conditions_table_comment)
      change_column_comment(:friendly_conditions, :benefit_id, benefit_id_comment)
      change_column_comment(:friendly_conditions, :preferences, preferences_comment)
    end
  end

  private

  def friendly_conditions_table_comment
    <<~COMMENT
      Represents a promotion benefit condition. A promotion benefit may have many conditions, which determine whether the benefit is eligible.
      All conditions must be eligible for the benefit to be eligible. If there are no conditions, the benefit is always eligible.
    COMMENT
  end

  def benefit_id_comment
    <<~COMMENT
      Foreign key to the friendly_benefits table.
    COMMENT
  end

  def preferences_comment
    <<~COMMENT
      Preferences for this promotion condition. Serialized YAML column with preferences for this promotion condition.
    COMMENT
  end
end
