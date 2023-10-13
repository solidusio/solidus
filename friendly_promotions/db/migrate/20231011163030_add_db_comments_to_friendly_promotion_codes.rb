# frozen_string_literal: true

class AddDbCommentsToFriendlyPromotionCodes < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_promotion_codes, friendly_promotion_codes_table_comment)
      change_column_comment(:friendly_promotion_codes, :id, id_comment)
      change_column_comment(:friendly_promotion_codes, :promotion_id, promotion_id_comment)
      change_column_comment(:friendly_promotion_codes, :value, value_comment)
      change_column_comment(:friendly_promotion_codes, :created_at, created_at_comment)
      change_column_comment(:friendly_promotion_codes, :updated_at, updated_at_comment)
      change_column_comment(:friendly_promotion_codes, :promotion_code_batch_id, promotion_code_batch_id_comment)
    end
  end

  private

  def friendly_promotion_codes_table_comment
    <<~COMMENT
      Promotions can have many promotion codes. This table is a collection of those codes.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def promotion_id_comment
    <<~COMMENT
      Foreign key to the friendly_promotions table.
    COMMENT
  end

  def value_comment
    <<~COMMENT
      The actual code, such as "BOATLIFE" for example.
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

  def promotion_code_batch_id_comment
    <<~COMMENT
      Foreign key to the friendly_promotion_code_batches table.
      If this promotion code was created using a promotion code batch, links to the batch.
    COMMENT
  end
end
