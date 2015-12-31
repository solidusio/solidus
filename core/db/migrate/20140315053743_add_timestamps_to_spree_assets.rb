class AddTimestampsToSolidusAssets < ActiveRecord::Migration
  def change
    add_column :solidus_assets, :created_at, :datetime
    add_column :solidus_assets, :updated_at, :datetime
  end
end
