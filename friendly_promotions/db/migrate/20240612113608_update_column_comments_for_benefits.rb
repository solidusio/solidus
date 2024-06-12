class UpdateColumnCommentsForBenefits < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_benefits, friendly_benefits_table_comment)
      change_column_comment(:friendly_benefits, :type, type_comment)
      change_column_comment(:friendly_benefits, :preferences, preferences_comment)
    end
  end

  private

  def friendly_benefits_table_comment
    <<~COMMENT
      Single Table inheritance table. Represents what to do to an order when the linked promotion is eligible.
      Promotions can have many benefits.
    COMMENT
  end

  def type_comment
    <<~COMMENT
      A class name representing which benefit this represents.
      Usually SolidusFriendlyPromotions::Benefits::Adjust{LineItem,Shipment}.
    COMMENT
  end

  def preferences_comment
    <<~COMMENT
      Preferences for this benefit. Serialized YAML.
    COMMENT
  end
end
