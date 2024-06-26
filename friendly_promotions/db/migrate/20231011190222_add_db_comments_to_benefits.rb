# frozen_string_literal: true

class AddDbCommentsToBenefits < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_benefits, solidus_promotions_benefits_table_comment)
      change_column_comment(:solidus_promotions_benefits, :id, id_comment)
      change_column_comment(:solidus_promotions_benefits, :promotion_id, promotion_id_comment)
      change_column_comment(:solidus_promotions_benefits, :type, type_comment)
      change_column_comment(:solidus_promotions_benefits, :preferences, preferences_comment)
      change_column_comment(:solidus_promotions_benefits, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_benefits, :updated_at, updated_at_comment)
    end
  end

  private

  def solidus_promotions_benefits_table_comment
    <<~COMMENT
      Single Table inheritance table. Represents what to do to an order when the linked promotion is eligible.
      Promotions can have many benefits.
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

  def type_comment
    <<~COMMENT
      A class name representing which benefit this represents.
      Usually SolidusFriendlyPromotions::PromotionAction::Adjust{LineItem,Shipment}.
    COMMENT
  end

  def preferences_comment
    <<~COMMENT
      Preferences for this benefit. Serialized YAML.
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
