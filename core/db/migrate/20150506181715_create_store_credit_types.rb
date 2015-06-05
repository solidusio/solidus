class CreateStoreCreditTypes < ActiveRecord::Migration
  def change
    create_table :spree_store_credit_types do |t|
      t.string :name
      t.integer :priority
      t.timestamps null: true
    end

    add_column :spree_store_credits, :type_id, :integer

    add_index :spree_store_credits, :type_id
    add_index :spree_store_credit_types, :priority

    Spree::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: Spree.t("store_credit.expiring"))
    Spree::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: Spree.t("store_credit.non_expiring"))
  end
end
