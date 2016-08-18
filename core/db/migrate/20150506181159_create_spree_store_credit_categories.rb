class CreateSpreeStoreCreditCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_store_credit_categories do |t|
      t.string :name
      t.timestamps null: true
    end

    Spree::StoreCreditCategory.find_or_create_by!(name: Spree.t("store_credit_category.default"))
  end
end
