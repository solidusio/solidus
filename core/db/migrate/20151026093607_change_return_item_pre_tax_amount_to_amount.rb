class ChangeReturnItemPreTaxAmountToAmount < ActiveRecord::Migration
  def up
    execute(<<-SQL)
      UPDATE spree_return_items
      SET included_tax_total = 0
      WHERE included_tax_total IS NULL
    SQL
    execute(<<-SQL)
      UPDATE spree_return_items
      SET pre_tax_amount = pre_tax_amount + included_tax_total
    SQL

    rename_column :spree_return_items, :pre_tax_amount, :amount
  end

  def down
    execute(<<-SQL)
      UPDATE spree_return_items
      SET included_tax_total = 0
      WHERE included_tax_total IS NULL
    SQL
    execute(<<-SQL)
      UPDATE spree_return_items
      SET amount = amount - included_tax_total
    SQL

    rename_column :spree_return_items, :amount, :pre_tax_amount
  end
end
