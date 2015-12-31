class CreateOrderMutex < ActiveRecord::Migration
  def change
    create_table :solidus_order_mutexes do |t|
      t.integer :order_id, null: false

      t.datetime :created_at
    end

    add_index :solidus_order_mutexes, :order_id, unique: true
  end
end
