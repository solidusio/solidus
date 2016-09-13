class CreateSpreeStoreCreditUpdateReasons < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_store_credit_update_reasons do |t|
      t.string :name
      t.timestamps null: true
    end
  end
end
