class CreateSpreeShippingRates < ActiveRecord::Migration
  def up
    create_table :solidus_shipping_rates do |t|
      t.belongs_to :shipment
      t.belongs_to :shipping_method
      t.boolean :selected, :default => false
      t.decimal :cost, :precision => 8, :scale => 2
      t.timestamps null: true
    end
    add_index(:solidus_shipping_rates, [:shipment_id, :shipping_method_id],
              :name => 'solidus_shipping_rates_join_index',
              :unique => true)

    # Solidus::Shipment.all.each do |shipment|
    #   shipping_method = Solidus::ShippingMethod.find(shipment.shipment_method_id)
    #   shipment.add_shipping_method(shipping_method, true)
    # end
  end

  def down
    # add_column :solidus_shipments, :shipping_method_id, :integer
    drop_table :solidus_shipping_rates
  end
end
