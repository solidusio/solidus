class AddUpdatedAtToVariants < ActiveRecord::Migration
  def change
    add_column :solidus_variants, :updated_at, :datetime
  end
end
