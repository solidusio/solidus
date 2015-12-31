class AddUpdatedAtToSpreeCountries < ActiveRecord::Migration
  def up
    add_column :solidus_countries, :updated_at, :datetime
  end

  def down
    remove_column :solidus_countries, :updated_at
  end
end
