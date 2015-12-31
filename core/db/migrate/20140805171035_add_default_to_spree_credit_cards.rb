class AddDefaultToSpreeCreditCards < ActiveRecord::Migration
  def change
    add_column :solidus_credit_cards, :default, :boolean, null: false, default: false
  end
end
