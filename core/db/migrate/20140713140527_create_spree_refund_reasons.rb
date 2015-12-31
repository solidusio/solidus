class CreateSolidusRefundReasons < ActiveRecord::Migration
  def change
    create_table :solidus_refund_reasons do |t|
      t.string :name
      t.boolean :active, default: true
      t.boolean :mutable, default: true

      t.timestamps null: true
    end

    add_column :solidus_refunds, :refund_reason_id, :integer
    add_index :solidus_refunds, :refund_reason_id, name: 'index_refunds_on_refund_reason_id'
  end
end
