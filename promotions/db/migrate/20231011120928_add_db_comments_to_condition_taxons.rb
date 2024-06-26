# frozen_string_literal: true

class AddDbCommentsToConditionTaxons < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_condition_taxons, solidus_promotions_condition_taxons_table_comment)
      change_column_comment(:solidus_promotions_condition_taxons, :id, id_comment)
      change_column_comment(:solidus_promotions_condition_taxons, :taxon_id, taxon_id_comment)
      change_column_comment(:solidus_promotions_condition_taxons, :condition_id, condition_id_comment)
      change_column_comment(:solidus_promotions_condition_taxons, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_condition_taxons, :updated_at, updated_at_comment)
    end
  end

  private

  def solidus_promotions_condition_taxons_table_comment
    <<~COMMENT
      Join table between promotion conditions and taxons. Only used if the promotion rule's type is SolidusPromotions::Conditions::Taxon or
      SolidusPromotions::Conditions::LineItemTaxon. Represents those taxons that the promotion rule matches on using its any/all/none
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
      Foreign key to the spree_taxons table.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the solidus_promotions_conditions table.
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
