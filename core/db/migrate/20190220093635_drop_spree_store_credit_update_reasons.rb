# frozen_string_literal: true

require "spree/migration"

class DropSpreeStoreCreditUpdateReasons < Spree::Migration
  # This migration should run in a subsequent deploy after 20180710170104
  # has been already deployed. See also migration 20180710170104.

  # We can't add back the table in a `down` method here: a previous version
  # of migration 20180710170104 would fail with `table already exists` , as
  # it handles itself the add/remove of this table and column.
  def up
    if table_exists? :spree_store_credit_update_reasons
      drop_table :spree_store_credit_update_reasons
    end

    if column_exists? :spree_store_credit_events, :update_reason_id
      remove_column :spree_store_credit_events, :update_reason_id
    end
  end
end
