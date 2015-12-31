class SplitPricesFromVariants < ActiveRecord::Migration
  def up
    create_table :solidus_prices do |t|
      t.integer :variant_id, :null => false
      t.decimal :amount, :precision => 8, :scale => 2, :null => false
      t.string :currency
    end

    Solidus::Variant.all.each do |variant|
      Solidus::Price.create!(
        :variant_id => variant.id,
        :amount => variant[:price],
        :currency => Solidus::Config[:currency]
      )
    end

    remove_column :solidus_variants, :price
  end

  def down
    prices = ActiveRecord::Base.connection.execute("select variant_id, amount from solidus_prices")
    add_column :solidus_variants, :price, :decimal, :after => :sku, :scale => 2, :precision => 8

    prices.each do |price|
      ActiveRecord::Base.connection.execute("update solidus_variants set price = #{price['amount']} where id = #{price['variant_id']}")
    end
    
    change_column :solidus_variants, :price, :decimal, :after => :sku, :scale => 2, :precision => 8, :null => false
    drop_table :solidus_prices
  end
end
