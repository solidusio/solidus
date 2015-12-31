class AddTaxCategoryIdToSpreeLineItems < ActiveRecord::Migration
  def change
    add_column :solidus_line_items, :tax_category_id, :integer
  end
end
