# frozen_string_literal: true

class AddCustomerLabelToPromotions < ActiveRecord::Migration[7.0]
  def change
    add_column :friendly_promotions, :customer_label, :string
  end
end
