class UpdateColumnCommentsForConditionTaxons < ActiveRecord::Migration[7.0]
  def up
    if connection.supports_comments?
      change_table_comment(:friendly_condition_taxons, friendly_condition_taxons_table_comment)
      change_column_comment(:friendly_condition_taxons, :condition_id, condition_id_comment)
    end
  end

  private

  def friendly_condition_taxons_table_comment
    <<~COMMENT
      Join table between conditions and taxons. Only used if the promotion condition's type is SolidusFriendlyPromotion::Conditions::Taxon or
      SolidusFriendlyPromotion::Conditions::LineItemTaxon. Represents those taxons that the promotion condition matches on using its any/all/none
      or include/exclude match policy.
    COMMENT
  end

  def condition_id_comment
    <<~COMMENT
      Foreign key to the friendly_conditions table.
    COMMENT
  end
end
