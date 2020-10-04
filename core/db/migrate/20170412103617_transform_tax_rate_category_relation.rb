# frozen_string_literal: true

class TransformTaxRateCategoryRelation < ActiveRecord::Migration[5.0]
  class TaxRate < ActiveRecord::Base
    self.table_name = "spree_tax_rates"
  end

  class TaxRateTaxCategory < ActiveRecord::Base
    self.table_name = "spree_tax_rate_tax_categories"
  end

  def up
    create_table :spree_tax_rate_tax_categories do |t|
      t.integer :tax_category_id, index: true, null: false
      t.integer :tax_rate_id, index: true, null: false
    end

    add_foreign_key :spree_tax_rate_tax_categories, :spree_tax_categories, column: :tax_category_id
    add_foreign_key :spree_tax_rate_tax_categories, :spree_tax_rates, column: :tax_rate_id

    TaxRate.where.not(tax_category_id: nil).find_each do |tax_rate|
      TaxRateTaxCategory.create!(
        tax_rate_id: tax_rate.id,
        tax_category_id: tax_rate.tax_category_id
      )
    end

    remove_column :spree_tax_rates, :tax_category_id
  end

  def down
    add_column :spree_tax_rates, :tax_category_id, :integer, index: true
    add_foreign_key :spree_tax_rates, :spree_tax_categories, column: :tax_category_id

    TaxRate.find_each do |tax_rate|
      tax_category_ids = TaxRateTaxCategory.where(tax_rate_id: tax_rate.id).pluck(:tax_category_id)

      tax_category_ids.each_with_index do |category_id, i|
        if i.zero?
          tax_rate.update!(tax_category_id: category_id)
        else
          new_tax_rate = tax_rate.dup
          new_tax_rate.update!(tax_category_id: category_id)
        end
      end
    end

    drop_table :spree_tax_rate_tax_categories
  end
end
