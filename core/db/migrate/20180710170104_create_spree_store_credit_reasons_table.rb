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

    add_column :spree_store_credit_events, :store_credit_reason_id, :integer
    execute "update spree_store_credit_events set store_credit_reason_id = update_reason_id"

    # TODO: table spree_store_credit_update_reasons and column
    # column spree_store_credit_update_reasons.update_reason_id
    # must be dropped in a future Solidus release
  end

  def down
    # This table and column  may not exist anymore as another irreversible
    # migration may have removed it later. They must be added back or the
    # `up` method would fail
    unless table_exists? :spree_store_credit_update_reasons
      create_table :spree_store_credit_update_reasons do |t|
        t.string :name

        t.timestamps
      end

      unless column_exists? :spree_store_credit_events, :update_reason_id
        add_column :spree_store_credit_events, :update_reason_id, :integer
      end
    end

    StoreCreditReason.all.each do |store_credit_reason|
      StoreCreditUpdateReason.create!(name: store_credit_reason.name)
    end

    drop_table :spree_store_credit_reasons
    remove_column :spree_store_credit_events, :store_credit_reason_id
  end
end
