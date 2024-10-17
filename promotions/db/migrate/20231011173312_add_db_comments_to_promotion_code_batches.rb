# frozen_string_literal: true

class AddDbCommentsToPromotionCodeBatches < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_promotion_code_batches, solidus_promotions_promotion_code_batches_table_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :id, id_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :promotion_id, promotion_id_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :base_code, base_code_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :number_of_codes, number_of_codes_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :email, email_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :error, error_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :state, state_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :updated_at, updated_at_comment)
      change_column_comment(:solidus_promotions_promotion_code_batches, :join_characters, join_characters_comment)
    end
  end

  private

  def solidus_promotions_promotion_code_batches_table_comment
    <<~COMMENT
      We allow creating a large number of promotion codes automatically through a background job. This table collects the input
      for creating such a batch of promotion codes.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def promotion_id_comment
    <<~COMMENT
      Foreign key to the solidus_promotions_promotions table.
    COMMENT
  end

  def base_code_comment
    <<~COMMENT
      The base code of this promotion code batch, such as "BOATLIFE".
    COMMENT
  end

  def number_of_codes_comment
    <<~COMMENT
      How many codes should be generated.
    COMMENT
  end

  def email_comment
    <<~COMMENT
      After the batch has been created, or in the event of an error, notify this email address.
    COMMENT
  end

  def error_comment
    <<~COMMENT
      Error that has occurred during batch processing, if any.
    COMMENT
  end

  def state_comment
    <<~COMMENT
      What the state of the promotion code batch is:
      - pending
      - processing
      - completed
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

  def join_characters_comment
    <<~COMMENT
      What characters to use for joining the base code with the individual extension, such as "_" for creating "BOATLIFE_S3CR3T".
    COMMENT
  end
end
