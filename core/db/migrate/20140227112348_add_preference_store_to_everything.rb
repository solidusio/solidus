class AddPreferenceStoreToEverything < ActiveRecord::Migration
  def change
    add_column :solidus_calculators, :preferences, :text
    add_column :solidus_gateways, :preferences, :text
    add_column :solidus_payment_methods, :preferences, :text
    add_column :solidus_promotion_rules, :preferences, :text
  end
end
