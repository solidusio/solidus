class CreateSpreeStoreCreditCategories < ActiveRecord::Migration
  def change
    create_table :spree_store_credit_categories do |t|
      t.string :name
      t.timestamps null: true
    end

    Solidus::StoreCreditCategory.find_or_create_by!(name: Solidus.t("store_credit_category.default"))
  end
end
