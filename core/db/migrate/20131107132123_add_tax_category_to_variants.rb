class AddTaxCategoryToVariants < ActiveRecord::Migration
  def change
    add_column :solidus_variants, :tax_category_id, :integer
    add_index  :solidus_variants, :tax_category_id
  end
end
