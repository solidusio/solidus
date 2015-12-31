class RemovePromotionsEventNameField < ActiveRecord::Migration
  def change
    remove_column :solidus_promotions, :event_name
  end
end
