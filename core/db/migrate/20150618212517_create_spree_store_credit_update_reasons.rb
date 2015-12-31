class CreateSpreeStoreCreditUpdateReasons < ActiveRecord::Migration
  def change
    create_table :solidus_store_credit_update_reasons do |t|
      t.string :name
      t.timestamps null: true
    end
  end
end
