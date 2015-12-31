class CopyShippedShipmentsToCartons < ActiveRecord::Migration
  # Prevent everything from running in one giant transaction in postrgres.
  disable_ddl_transaction!

  def up
    Rake::Task["solidus:migrations:copy_shipped_shipments_to_cartons:up"].invoke
  end

  def down
    Rake::Task["solidus:migrations:copy_shipped_shipments_to_cartons:down"].invoke
  end

end
