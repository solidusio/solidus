class CreateSolidusTaxonsPromotionRules < ActiveRecord::Migration
  def change
    create_table :solidus_taxons_promotion_rules do |t|
      t.references :taxon, index: true
      t.references :promotion_rule, index: true
    end
  end
end
