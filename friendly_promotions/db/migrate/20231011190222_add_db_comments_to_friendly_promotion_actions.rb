# frozen_string_literal: true

class AddDbCommentsToFriendlyPromotionActions < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_promotion_actions, friendly_promotion_actions_table_comment)
      change_column_comment(:friendly_promotion_actions, :id, id_comment)
      change_column_comment(:friendly_promotion_actions, :promotion_id, promotion_id_comment)
      change_column_comment(:friendly_promotion_actions, :type, type_comment)
      change_column_comment(:friendly_promotion_actions, :deleted_at, deleted_at_comment)
      change_column_comment(:friendly_promotion_actions, :preferences, preferences_comment)
      change_column_comment(:friendly_promotion_actions, :created_at, created_at_comment)
      change_column_comment(:friendly_promotion_actions, :updated_at, updated_at_comment)
    end
  end

  private

  def friendly_promotion_actions_table_comment
    <<~COMMENT
      Single Table inheritance table. Represents what to do to an order when the linked promotion is eligible.
      Promotions can have many promotion actions.
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

  def type_comment
    <<~COMMENT
      A class name representing which promotion action this represents.
      Usually SolidusFriendlyPromotions::PromotionAction::Adjust{LineItem,Shipment}.
    COMMENT
  end

  def deleted_at_comment
    <<~COMMENT
      Timestamp indicating if and when this record was soft-deleted.
    COMMENT
  end

  def preferences_comment
    <<~COMMENT
      Preferences for this promotion action. Serialized YAML.
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
