class AddCodeToSpreePromotionRules < ActiveRecord::Migration
  def change
    add_column :solidus_promotion_rules, :code, :string
  end
end
