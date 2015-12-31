class IncreaseScaleOnPreTaxAmounts < ActiveRecord::Migration
  def change
    # set pre_tax_amount on shipments to discounted_amount - included_tax_total
    # so that the null: false option on the shipment pre_tax_amount doesn't generate
    # errors.
    #
    execute(<<-SQL)
      UPDATE solidus_shipments
      SET pre_tax_amount = (cost + promo_total) - included_tax_total
      WHERE pre_tax_amount IS NULL;
    SQL

    # set pre_tax_amount on line_items to discounted_amount - included_tax_total
    # so that the null: false option on the line_item pre_tax_amount doesn't generate
    # errors.
    #
    execute(<<-SQL)
      UPDATE solidus_line_items
      SET pre_tax_amount = (price * quantity + promo_total) - included_tax_total
      WHERE pre_tax_amount IS NULL;
    SQL

    change_column :solidus_line_items, :pre_tax_amount, :decimal, precision: 12, scale: 4, default: 0.0, null: false
    change_column :solidus_shipments, :pre_tax_amount, :decimal, precision: 12, scale: 4, default: 0.0, null: false
  end
end
