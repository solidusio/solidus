class DisallowAdjustmentFinalizedNulls < ActiveRecord::Migration
  def up
    execute <<-SQL
      update spree_adjustments
      set finalized = #{ActiveRecord::Base.connection.quoted_false}
      where finalized is null
    SQL

    change_table :spree_adjustments do |t|
      t.change :finalized, :boolean, null: false, default: false
    end
  end

  def down
    change_table :spree_adjustments do |t|
      t.change :finalized, :boolean, null: true, default: nil
    end
  end
end
