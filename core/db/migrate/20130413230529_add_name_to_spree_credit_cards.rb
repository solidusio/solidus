class AddNameToSolidusCreditCards < ActiveRecord::Migration
  def change
    add_column :solidus_credit_cards, :name, :string
  end
end
