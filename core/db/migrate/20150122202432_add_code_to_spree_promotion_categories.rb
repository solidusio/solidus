class AddCodeToSpreePromotionCategories < ActiveRecord::Migration
  def change
    add_column :solidus_promotion_categories, :code, :string
  end
end
