class AddReceptionAndAcceptanceStatusToReturnItems < ActiveRecord::Migration
  def change
    add_column :solidus_return_items, :reception_status, :string
    add_column :solidus_return_items, :acceptance_status, :string
  end
end
