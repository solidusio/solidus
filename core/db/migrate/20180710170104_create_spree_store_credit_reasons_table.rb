# frozen_string_literal: true

class CreateSpreeStoreCreditReasonsTable < ActiveRecord::Migration[5.1]
  class StoreCreditUpdateReason < ActiveRecord::Base
    self.table_name = "spree_store_credit_update_reasons"
  end

  class StoreCreditReason < ActiveRecord::Base
    self.table_name = "spree_store_credit_reasons"
  end

  def up
    create_table :spree_store_credit_reasons do |t|
      t.string :name
      t.boolean :active, default: true

      t.timestamps
    end

    StoreCreditUpdateReason.all.each do |update_reason|
      StoreCreditReason.create!(name: update_reason.name)
    end

    drop_table :spree_store_credit_update_reasons
    rename_column :spree_store_credit_events, :update_reason_id, :store_credit_reason_id
  end

  def down
    create_table :spree_store_credit_update_reasons do |t|
      t.string :name

      t.timestamps
    end

    StoreCreditReason.all.each do |store_credit_reason|
      StoreCreditUpdateReason.create!(name: store_credit_reason.name)
    end

    drop_table :spree_store_credit_reasons
    rename_column :spree_store_credit_events, :store_credit_reason_id, :update_reason_id
  end
end
