class AddCodeToSolidusTaxCategories < ActiveRecord::Migration
  def change
    add_column :solidus_tax_categories, :tax_code, :string
  end
end
