# frozen_string_literal: true

class AddDbCommentsToPromotionCategories < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_promotion_categories, solidus_promotions_promotion_categories_table_comment)
      change_column_comment(:solidus_promotions_promotion_categories, :id, id_comment)
      change_column_comment(:solidus_promotions_promotion_categories, :name, name_comment)
      change_column_comment(:solidus_promotions_promotion_categories, :code, code_comment)
      change_column_comment(:solidus_promotions_promotion_categories, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_promotion_categories, :updated_at, updated_at_comment)
    end
  end

  private

  def solidus_promotions_promotion_categories_table_comment
    <<~COMMENT
      Category that helps admins index promotions.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def name_comment
    <<~COMMENT
      Name of this promotion category.
    COMMENT
  end

  def code_comment
    <<~COMMENT
      Code of this promotion category.
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
