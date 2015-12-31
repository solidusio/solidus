class RecreateSolidusReturnAuthorizations < ActiveRecord::Migration
  def up
    # If the app has any legacy return authorizations then rename the table & columns and leave them there
    # for the solidus_legacy_return_authorizations extension to pick up with.
    # Otherwise just drop the tables/columns as they are no longer used in stock solidus.  The solidus_legacy_return_authorizations
    # extension will recreate these tables for dev environments & etc as needed.
    if Solidus::ReturnAuthorization.exists?
      rename_table :solidus_return_authorizations, :solidus_legacy_return_authorizations
      rename_column :solidus_inventory_units, :return_authorization_id, :legacy_return_authorization_id
    else
      drop_table :solidus_return_authorizations
      remove_column :solidus_inventory_units, :return_authorization_id
    end

    Solidus::Adjustment.where(source_type: 'Solidus::ReturnAuthorization').update_all(source_type: 'Solidus::LegacyReturnAuthorization')

    # For now just recreate the table as it was.  Future changes to the schema (including dropping "amount") will be coming in a
    # separate commit.
    create_table :solidus_return_authorizations do |t|
      t.string   "number"
      t.string   "state"
      t.decimal  "amount", precision: 10, scale: 2, default: 0.0, null: false
      t.integer  "order_id"
      t.text     "reason"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "stock_location_id"
    end

  end

  def down
    drop_table :solidus_return_authorizations

    Solidus::Adjustment.where(source_type: 'Solidus::LegacyReturnAuthorization').update_all(source_type: 'Solidus::ReturnAuthorization')

    if table_exists?(:solidus_legacy_return_authorizations)
      rename_table :solidus_legacy_return_authorizations, :solidus_return_authorizations
      rename_column :solidus_inventory_units, :legacy_return_authorization_id, :return_authorization_id
    else
      create_table :solidus_return_authorizations do |t|
        t.string   "number"
        t.string   "state"
        t.decimal  "amount", precision: 10, scale: 2, default: 0.0, null: false
        t.integer  "order_id"
        t.text     "reason"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.integer  "stock_location_id"
      end
      add_column :solidus_inventory_units, :return_authorization_id, :integer, after: :shipment_id
      add_index :solidus_inventory_units, :return_authorization_id
    end
  end
end
