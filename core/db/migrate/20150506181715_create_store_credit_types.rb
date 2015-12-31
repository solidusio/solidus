class CreateStoreCreditTypes < ActiveRecord::Migration
  def change
    create_table :solidus_store_credit_types do |t|
      t.string :name
      t.integer :priority
      t.timestamps null: true
    end

    add_column :solidus_store_credits, :type_id, :integer

    add_index :solidus_store_credits, :type_id
    add_index :solidus_store_credit_types, :priority

    Solidus::StoreCreditType.create_with(priority: 1).find_or_create_by!(name: Solidus.t("store_credit.expiring"))
    Solidus::StoreCreditType.create_with(priority: 2).find_or_create_by!(name: Solidus.t("store_credit.non_expiring"))
  end
end
