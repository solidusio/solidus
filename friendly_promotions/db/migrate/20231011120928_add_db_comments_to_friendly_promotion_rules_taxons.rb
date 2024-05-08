# frozen_string_literal: true

class AddDbCommentsToFriendlyPromotionRulesTaxons < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_promotion_rules_taxons, friendly_promotion_rules_taxons_table_comment)
      change_column_comment(:friendly_promotion_rules_taxons, :id, id_comment)
      change_column_comment(:friendly_promotion_rules_taxons, :taxon_id, taxon_id_comment)
      change_column_comment(:friendly_promotion_rules_taxons, :promotion_rule_id, promotion_rule_id_comment)
      change_column_comment(:friendly_promotion_rules_taxons, :created_at, created_at_comment)
      change_column_comment(:friendly_promotion_rules_taxons, :updated_at, updated_at_comment)
    end
  end

  private

  def friendly_promotion_rules_taxons_table_comment
    <<~COMMENT
      Join table between promotion rules and taxons. Only used if the promotion rule's type is SolidusFriendlyPromotion::Conditions::Taxon or
      SolidusFriendlyPromotion::Conditions::LineItemTaxon. Represents those taxons that the promotion rule matches on using its any/all/none
      or include/exclude match policy.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def taxon_id_comment
    <<~COMMENT
      Foreign key to the taxons table.
    COMMENT
  end

  def promotion_rule_id_comment
    <<~COMMENT
      Foreign key to the friendly_promotion_rules table.
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
