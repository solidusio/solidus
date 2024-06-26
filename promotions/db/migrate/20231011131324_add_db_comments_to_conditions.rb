# frozen_string_literal: true

class AddDbCommentsToConditions < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_conditions, solidus_promotions_conditions_table_comment)
      change_column_comment(:solidus_promotions_conditions, :id, id_comment)
      change_column_comment(:solidus_promotions_conditions, :benefit_id, benefit_id_comment)
      change_column_comment(:solidus_promotions_conditions, :type, type_comment)
      change_column_comment(:solidus_promotions_conditions, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_conditions, :updated_at, updated_at_comment)
      change_column_comment(:solidus_promotions_conditions, :preferences, preferences_comment)
    end
  end

  private

  def solidus_promotions_conditions_table_comment
    <<~COMMENT
      Represents promotion conditions. A benefit may have many conditions, which determine whether the benefit is eligible.
      All rules must be eligible for the benefit to be eligible. If there are no rules, the benefit is always eligible.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def benefit_id_comment
    <<~COMMENT
      Foreign key to the benefits table.
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
      Preferences for this condition. Serialized YAML column with preferences for this condition.
    COMMENT
  end
end
