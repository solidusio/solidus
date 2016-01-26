class FixAdjustmentOrderId < ActiveRecord::Migration
  def change
    say 'Populate order_id from adjustable_id where appropriate'

    # 3 separate execute calls to workaround MySQL limitation
    execute(<<-'SQL'.squish)
      UPDATE
        spree_adjustments
      SET
        order_id = adjustable_id
      WHERE
            adjustable_type = 'Spree::Order'
        AND order_id IS NULL
    SQL

    execute(<<-'SQL'.squish)
      UPDATE
        spree_adjustments
      SET
        order_id =
          (SELECT order_id FROM spree_line_items WHERE spree_line_items.id = spree_adjustments.adjustable_id)
      WHERE
            adjustable_type = 'Spree::LineItem'
        AND order_id IS NULL
      ;
    SQL

    execute(<<-'SQL'.squish)
      UPDATE
        spree_adjustments
      SET
        order_id =
          (SELECT order_id FROM spree_shipments WHERE spree_shipments.id = spree_adjustments.adjustable_id)
      WHERE
            adjustable_type = 'Spree::Shipment'
        AND order_id IS NULL
    SQL

    say 'Fix schema for spree_adjustments order_id column'
    change_table :spree_adjustments do |t|
      t.change :order_id,      :integer, null: false
      t.change :adjustable_id, :integer, null: false

      add_foreign_key :spree_adjustments,
                      :spree_orders,
                      name:      'fk_spree_adjustments_order_id', # default is indeterministic
                      column:    :order_id,
                      on_delete: :restrict, # handled by models
                      on_update: :restrict  # handled by models
    end

    if connection.adapter_name.eql?('PostgreSQL')
      # Negated Logical implication.
      #
      # When adjustable_type is 'Spree::Order' (p) the adjustable_id must be order_id (q).
      #
      # When adjustable_type is NOT 'Spree::Order' the adjustable id allowed to be any value (including of order_id in
      # case foreign keys match). XOR does not work here.
      #
      # Postgresql does not have an operator for logical implication. So we need to build the following truth table
      # via AND with OR:
      #
      #  p q | CHECK = !(p -> q)
      #  -----------
      #  t t | t
      #  t f | f
      #  f t | t
      #  f f | t
      #
      # According to de-morgans law the logical implication q -> p is equivalent to !p || q
      #
      execute(<<-SQL.squish)
        ALTER TABLE ONLY spree_adjustments
          ADD CONSTRAINT check_spree_adjustments_order_id CHECK
            (adjustable_type <> 'Spree::Order' OR order_id = adjustable_id);
      SQL
    end
  end
end
